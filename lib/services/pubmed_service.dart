import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/models.dart';

/// Service for searching PubMed via E-utilities API.
///
/// Rate limit: 3 req/sec without API key. We enforce this client-side.
/// Cache: results stored in Hive box 'pubmed_cache' keyed by PMID.
class PubMedService {
  static const _baseUrl = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils';
  static const _tool = 'zebraupp';
  static const _email = 'beta@zebraupp.app'; // NCBI prefers an email
  static const _cacheBoxName = 'pubmed_cache';
  static const _cacheStalenessHours = 24; // refresh after 24h

  /// 3 req/sec → 334ms minimum spacing. We use 400ms to be safe.
  static const _minRequestSpacing = Duration(milliseconds: 400);
  DateTime _lastRequestAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Throttle helper.
  Future<void> _throttle() async {
    final now = DateTime.now();
    final since = now.difference(_lastRequestAt);
    if (since < _minRequestSpacing) {
      await Future.delayed(_minRequestSpacing - since);
    }
    _lastRequestAt = DateTime.now();
  }

  Box<dynamic>? _box;
  Future<Box<dynamic>> _getBox() async {
    _box ??= await Hive.openBox(_cacheBoxName);
    return _box!;
  }

  /// Search PubMed for a given condition. Returns articles, sorted by relevance.
  ///
  /// Strategy:
  /// 1. Check cache — if we have fresh results for this condition, return them
  /// 2. Otherwise, esearch to get PMIDs, then esummary for metadata
  /// 3. Cache everything
  /// 4. On network failure, return stale cache if available
  Future<PubMedSearchResult> searchForCondition({
    required String condition,
    int maxResults = 10,
    int recentDays = 365,
    bool forceRefresh = false,
  }) async {
    final box = await _getBox();
    final cacheKey = 'search:${condition.toLowerCase()}';
    final cachedRaw = box.get(cacheKey);

    // Try to deserialize cache
    PubMedSearchResult? cached;
    if (cachedRaw != null) {
      try {
        cached = PubMedSearchResult.fromMap(
            Map<String, dynamic>.from(jsonDecode(cachedRaw as String)));
      } catch (e) {
        debugPrint('PubMed cache decode failed: $e');
      }
    }

    // Return fresh cache if available and not forced to refresh
    if (!forceRefresh && cached != null && !cached.isStale) {
      return cached;
    }

    // Try network
    try {
      final pmids = await _esearch(condition, maxResults, recentDays);
      if (pmids.isEmpty) {
        final empty = PubMedSearchResult(
          condition: condition,
          articles: [],
          fetchedAt: DateTime.now(),
          fromCache: false,
        );
        await box.put(cacheKey, jsonEncode(empty.toMap()));
        return empty;
      }
      final articles = await _esummary(pmids, condition);
      final result = PubMedSearchResult(
        condition: condition,
        articles: articles,
        fetchedAt: DateTime.now(),
        fromCache: false,
      );
      // Cache individual articles too (for the saved library)
      for (final a in articles) {
        await box.put('article:${a.pmid}', jsonEncode(a.toMap()));
      }
      await box.put(cacheKey, jsonEncode(result.toMap()));
      return result;
    } catch (e) {
      debugPrint('PubMed fetch failed: $e');
      // Network failed — return stale cache if we have it
      if (cached != null) {
        return cached.copyWith(fromCache: true);
      }
      // No cache, no network — return empty with error flag
      return PubMedSearchResult(
        condition: condition,
        articles: [],
        fetchedAt: DateTime.now(),
        fromCache: false,
        error: _humanError(e),
      );
    }
  }

  /// Returns PMIDs for the user's saved articles, hydrated from cache.
  /// Falls back to network for any missing ones.
  Future<List<PubMedArticle>> getSavedArticles(Set<String> pmids) async {
    if (pmids.isEmpty) return [];
    final box = await _getBox();
    final results = <PubMedArticle>[];
    final missing = <String>[];

    for (final pmid in pmids) {
      final raw = box.get('article:$pmid');
      if (raw != null) {
        try {
          results.add(PubMedArticle.fromMap(
              Map<String, dynamic>.from(jsonDecode(raw as String))));
        } catch (_) {
          missing.add(pmid);
        }
      } else {
        missing.add(pmid);
      }
    }

    if (missing.isNotEmpty) {
      try {
        final fetched = await _esummary(missing, '');
        for (final a in fetched) {
          await box.put('article:${a.pmid}', jsonEncode(a.toMap()));
        }
        results.addAll(fetched);
      } catch (e) {
        debugPrint('PubMed saved-article fetch failed: $e');
      }
    }

    results.sort((a, b) => b.publicationDate.compareTo(a.publicationDate));
    return results;
  }

  // --- Internal API calls ---

  Future<List<String>> _esearch(String term, int maxResults, int recentDays) async {
    await _throttle();
    final encodedTerm = Uri.encodeComponent(term);
    final uri = Uri.parse(
        '$_baseUrl/esearch.fcgi?db=pubmed&term=$encodedTerm'
        '&retmax=$maxResults&sort=relevance&reldate=$recentDays'
        '&datetype=pdat&retmode=json&tool=$_tool&email=$_email');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw _PubMedException('esearch HTTP ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final esearchResult = body['esearchresult'] as Map<String, dynamic>?;
    if (esearchResult == null) {
      throw _PubMedException('esearch malformed response');
    }
    final idList = esearchResult['idlist'] as List<dynamic>? ?? [];
    return idList.map((e) => e.toString()).toList();
  }

  Future<List<PubMedArticle>> _esummary(List<String> pmids, String condition) async {
    if (pmids.isEmpty) return [];
    await _throttle();
    final uri = Uri.parse('$_baseUrl/esummary.fcgi?db=pubmed&id=${pmids.join(",")}'
        '&retmode=json&tool=$_tool&email=$_email');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw _PubMedException('esummary HTTP ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final result = body['result'] as Map<String, dynamic>?;
    if (result == null) {
      throw _PubMedException('esummary malformed response');
    }
    final articles = <PubMedArticle>[];
    for (final pmid in pmids) {
      final raw = result[pmid] as Map<String, dynamic>?;
      if (raw == null) continue;
      final article = _articleFromSummary(pmid, raw, condition);
      if (article != null) articles.add(article);
    }
    return articles;
  }

  PubMedArticle? _articleFromSummary(String pmid, Map<String, dynamic> raw, String condition) {
    try {
      final title = (raw['title'] as String?)?.trim() ?? 'Sin título';
      final journal = (raw['fulljournalname'] as String?) ??
          (raw['source'] as String?) ??
          '';
      final authorsRaw = raw['authors'] as List<dynamic>? ?? [];
      final authors = authorsRaw
          .map((a) => (a as Map<String, dynamic>)['name'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      DateTime pubDate;
      try {
        pubDate = DateTime.parse(raw['sortpubdate'] as String? ?? raw['pubdate'] as String);
      } catch (_) {
        // PubMed pubdates can be "2024 Mar" or "2024" — fall back
        final s = (raw['pubdate'] as String?) ?? '';
        pubDate = DateTime.tryParse(s) ??
            DateTime.tryParse('$s-01-01') ??
            DateTime.now();
      }
      return PubMedArticle(
        pmid: pmid,
        title: title,
        journal: journal,
        authors: authors,
        publicationDate: pubDate,
        fetchedForConditions: condition.isEmpty ? [] : [condition],
      );
    } catch (e) {
      debugPrint('PubMed parse fail for $pmid: $e');
      return null;
    }
  }

  /// Fetch the abstract for a single article (lazy, only when user taps).
  Future<String?> fetchAbstract(String pmid) async {
    final box = await _getBox();
    final cacheKey = 'abstract:$pmid';
    final cached = box.get(cacheKey) as String?;
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      await _throttle();
      final uri = Uri.parse('$_baseUrl/efetch.fcgi?db=pubmed&id=$pmid'
          '&rettype=abstract&retmode=xml&tool=$_tool&email=$_email');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;
      final doc = XmlDocument.parse(response.body);
      final abstractNodes = doc.findAllElements('AbstractText');
      final parts = <String>[];
      for (final node in abstractNodes) {
        final label = node.getAttribute('Label');
        final text = node.innerText.trim();
        if (text.isEmpty) continue;
        parts.add(label != null ? '$label: $text' : text);
      }
      final abstract = parts.join('\n\n');
      if (abstract.isNotEmpty) {
        await box.put(cacheKey, abstract);
        return abstract;
      }
      return null;
    } catch (e) {
      debugPrint('PubMed abstract fetch failed: $e');
      return null;
    }
  }

  String _humanError(Object e) {
    final s = e.toString();
    if (s.contains('SocketException') || s.contains('Failed host lookup')) {
      return 'Sin conexión. Mostrando resultados guardados.';
    }
    if (s.contains('TimeoutException') || s.contains('Timeout')) {
      return 'La búsqueda tardó demasiado. Inténtalo más tarde.';
    }
    if (s.contains('429')) {
      return 'Demasiadas búsquedas en poco tiempo. Espera un momento.';
    }
    return 'No se pudo conectar a PubMed.';
  }
}

class _PubMedException implements Exception {
  final String message;
  _PubMedException(this.message);
  @override
  String toString() => 'PubMedException: $message';
}

/// A cached search result for one condition.
class PubMedSearchResult {
  final String condition;
  final List<PubMedArticle> articles;
  final DateTime fetchedAt;
  final bool fromCache;
  final String? error;

  PubMedSearchResult({
    required this.condition,
    required this.articles,
    required this.fetchedAt,
    required this.fromCache,
    this.error,
  });

  bool get isStale {
    return DateTime.now().difference(fetchedAt) >
        const Duration(hours: PubMedService._cacheStalenessHours);
  }

  PubMedSearchResult copyWith({bool? fromCache, String? error}) =>
      PubMedSearchResult(
        condition: condition,
        articles: articles,
        fetchedAt: fetchedAt,
        fromCache: fromCache ?? this.fromCache,
        error: error ?? this.error,
      );

  Map<String, dynamic> toMap() => {
        'condition': condition,
        'articles': articles.map((a) => a.toMap()).toList(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory PubMedSearchResult.fromMap(Map<String, dynamic> map) =>
      PubMedSearchResult(
        condition: map['condition'],
        articles: (map['articles'] as List)
            .map((a) => PubMedArticle.fromMap(Map<String, dynamic>.from(a)))
            .toList(),
        fetchedAt: DateTime.parse(map['fetchedAt']),
        fromCache: true,
      );
}