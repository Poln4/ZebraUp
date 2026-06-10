import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

/// Resolves user-entered condition names into ICD-10 codes, queries the
/// MedlinePlus Connect API for Spanish patient education content, and caches
/// results in Hive for 7 days.
///
/// API docs: https://medlineplus.gov/connect/service.html
class MedlinePlusService {
  static const _base = 'https://connect.medlineplus.gov/service';
  static const _cacheDays = 7;

  List<_ConditionMapping>? _mappings;

  /// One-time load of the alias → ICD-10 map. Idempotent.
  Future<void> _ensureMappingsLoaded() async {
    if (_mappings != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/condition_codes.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final list = (data['mappings'] as List?) ?? [];
      _mappings = list
          .map((m) => _ConditionMapping.fromMap(m as Map<String, dynamic>))
          .toList();
    } catch (_) {
      print("🚨 ERROR CARGANDO JSON: ");
      _mappings = [];
    }
  }

  /// Returns the ICD-10 code for a user-entered condition string, or null
  /// if no match. Case-insensitive, matches against aliases.
  Future<_ConditionMapping?> resolveCondition(String userInput) async {
    await _ensureMappingsLoaded();
    if (_mappings == null || _mappings!.isEmpty) return null;
    final norm = userInput.trim().toLowerCase();
    
    // 1. Exact match (Best scenario)
    for (final m in _mappings!) {
      for (final alias in m.aliases) {
        if (alias.toLowerCase() == norm) return m;
      }
    }
    
    // 2. Loose contains-match fallback.
    // FIX: Added a length guard. Without this, a user typing "do" 
    // might accidentally match "Endometriosis" or "Dolor".
    if (norm.length > 3) {
      for (final m in _mappings!) {
        for (final alias in m.aliases) {
          if (norm.contains(alias.toLowerCase()) ||
              alias.toLowerCase().contains(norm)) return m;
        }
      }
    }
    return null;
  }

  /// Fetches Spanish patient education content for an ICD-10 code.
  /// Implements hierarchical fallback (e.g., Q79.60 -> Q79.6 -> Q79).
  Future<MedlinePlusContent?> getContent(String icd10) async {
    final box = Hive.box('zebraBox');
    final cacheKey = 'medlineplus:$icd10';
    final cached = box.get(cacheKey) as String?;
    
    if (cached != null) {
      try {
        final m = jsonDecode(cached) as Map<String, dynamic>;
        final fetchedAt = DateTime.parse(m['fetchedAt'] as String);
        if (DateTime.now().difference(fetchedAt).inDays < _cacheDays) {
          return MedlinePlusContent.fromMap(m);
        }
      } catch (_) {
        // Corrupted cache — proceed to refetch.
      }
    }

    // Try exact ICD-10 code (e.g., Q79.60)
    MedlinePlusContent? content = await _fetchFromApi(icd10);

    // FIX: Hierarchical Fallback 1 - Try stripping deep sub-categories (e.g., Q79.60 -> Q79.6)
    if (content == null && icd10.contains('.')) {
      final parts = icd10.split('.');
      if (parts[1].length > 1) {
        final shorterIcd = '${parts[0]}.${parts[1].substring(0, 1)}';
        content = await _fetchFromApi(shorterIcd);
      }
    }

    // FIX: Hierarchical Fallback 2 - Try broad category (e.g., Q79.6 -> Q79)
    if (content == null && icd10.contains('.')) {
      final baseCode = icd10.split('.')[0];
      content = await _fetchFromApi(baseCode);
    }

    // Cache the result using the ORIGINAL icd10 key so we don't repeat the fallback cascade
    if (content != null) {
      final finalContent = MedlinePlusContent(
        icd10: icd10, // Maintain the original specific code in the object
        title: content.title,
        summary: content.summary,
        link: content.link,
        fetchedAt: DateTime.now(),
      );
      await box.put(cacheKey, jsonEncode(finalContent.toMap()));
      return finalContent;
    }

    return null;
  }

  /// Isolated API call logic to support clean hierarchical fallbacks
  Future<MedlinePlusContent?> _fetchFromApi(String queryIcd) async {
    final url = Uri.parse('$_base?'
        'mainSearchCriteria.v.cs=2.16.840.1.113883.6.90' // ICD-10-CM OID
        '&mainSearchCriteria.v.c=${Uri.encodeComponent(queryIcd)}'
        '&informationRecipient.languageCode.c=es'
        '&knowledgeResponseType=application/json');

    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final feed = data['feed'] as Map<String, dynamic>?;
      final entries = (feed?['entry'] as List?) ?? [];
      
      if (entries.isEmpty) return null;

      final first = entries.first as Map<String, dynamic>;
      
      final title = (first['title'] is Map)
          ? (first['title']['_value'] as String? ?? '')
          : (first['title'] as String? ?? '');
          
      final summary = (first['summary'] is Map)
          ? (first['summary']['_value'] as String? ?? '')
          : (first['summary'] as String? ?? '');
          
      String? link;
      final links = first['link'];
      if (links is List && links.isNotEmpty) {
        final l = links.first;
        if (l is Map) link = l['href'] as String?;
      } else if (links is Map) {
        link = links['href'] as String?;
      }

      return MedlinePlusContent(
        icd10: queryIcd,
        title: title.trim(),
        summary: _stripHtml(summary).trim(),
        link: link,
        fetchedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Quick HTML strip for the summary field
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<p\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}

class _ConditionMapping {
  final List<String> aliases;
  final String icd10;
  final String label;

  _ConditionMapping({required this.aliases, required this.icd10, required this.label});

  factory _ConditionMapping.fromMap(Map<String, dynamic> m) => _ConditionMapping(
        aliases: List<String>.from(m['aliases'] as List? ?? []),
        icd10: m['icd10'] as String,
        label: m['label'] as String,
      );
}

class MedlinePlusContent {
  final String icd10;
  final String title;
  final String summary;
  final String? link;
  final DateTime fetchedAt;

  MedlinePlusContent({
    required this.icd10,
    required this.title,
    required this.summary,
    this.link,
    required this.fetchedAt,
  });

  Map<String, dynamic> toMap() => {
        'icd10': icd10,
        'title': title,
        'summary': summary,
        'link': link,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory MedlinePlusContent.fromMap(Map<String, dynamic> m) => MedlinePlusContent(
        icd10: m['icd10'] as String,
        title: m['title'] as String,
        summary: m['summary'] as String,
        link: m['link'] as String?,
        fetchedAt: DateTime.parse(m['fetchedAt'] as String),
      );
}