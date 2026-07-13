// =============================================================================
// VademecumService — drug + condition information service.
//
// Phase 3a (June 2026): rename and refactor of the former MedlinePlusService.
// Two core changes vs. the old service:
//
//   1. Drug content is resolved through a LOCAL-FIRST cascade. The local
//      drug_codes.json is no longer just a mapping table — entries now
//      carry trilingual `summary_es/en/zh` content, `notes_*` clinical
//      warnings, and an `interactions[]` array of cross-references to
//      other meds. MedlinePlus is consulted only when the local entry
//      has no summary content, AND only for entries with an `rxcui`
//      (taiwanese commercials, supplements and herbals never go to
//      MedlinePlus — their content is local-only by design).
//
//   2. Real error logging in catch blocks. The old `catch (_)` swallowed
//      asset-load 404s and CORS errors silently — see the postmortem of
//      the drug_codes.json missing-from-pubspec bug. Each catch now
//      identifies its source so failures surface in the browser console.
//
// Naming compatibility: the file keeps a `MedlinePlusService` alias at
// the bottom so existing imports keep working through this sprint. A
// future cleanup sprint should migrate the imports to `VademecumService`
// and drop the alias.
//
// API docs (MedlinePlus Connect): https://medlineplus.gov/connect/service.html
// =============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';

/// What kind of product the entry describes. Drives UI presentation
/// (which icon, which disclaimer, whether to consult MedlinePlus).
enum VademecumKind {
  medication,
  supplement,
  herbal;

  static VademecumKind parse(String? raw) {
    if (raw == null) return VademecumKind.medication;
    for (final k in values) {
      if (k.name == raw) return k;
    }
    return VademecumKind.medication;
  }
}

/// Severity for a declared interaction.
enum InteractionSeverity {
  low,
  medium,
  high;

  static InteractionSeverity parse(String? raw) {
    if (raw == null) return InteractionSeverity.low;
    for (final s in values) {
      if (s.name == raw) return s;
    }
    return InteractionSeverity.low;
  }
}

/// Active locale tag for content selection. Keep this minimal — the
/// service doesn't need to know about regional sub-locales; it just
/// needs the language code.
enum VademecumLocale {
  es,
  en,
  zh;

  static VademecumLocale fromCode(String code) {
    final c = code.toLowerCase();
    if (c.startsWith('en')) return VademecumLocale.en;
    if (c.startsWith('zh')) return VademecumLocale.zh;
    return VademecumLocale.es;
  }
}

/// One declared interaction between this entry and another med.
/// `with_` is the alias of the other med (matched against any entry's
/// aliases case-insensitive).
class VademecumInteraction {
  final String withAlias;
  final InteractionSeverity severity;
  final String descriptionEs;
  final String descriptionEn;
  final String descriptionZh;

  VademecumInteraction({
    required this.withAlias,
    required this.severity,
    required this.descriptionEs,
    required this.descriptionEn,
    required this.descriptionZh,
  });

  String description(VademecumLocale locale) => switch (locale) {
    VademecumLocale.es => descriptionEs,
    VademecumLocale.en => descriptionEn,
    VademecumLocale.zh => descriptionZh,
  };

  factory VademecumInteraction.fromMap(Map<String, dynamic> m) =>
      VademecumInteraction(
        withAlias: m['with'] as String,
        severity: InteractionSeverity.parse(m['severity'] as String?),
        descriptionEs: m['description_es'] as String? ?? '',
        descriptionEn: m['description_en'] as String? ?? '',
        descriptionZh: m['description_zh'] as String? ?? '',
      );
}

/// One entry in drug_codes_v2.json. Internal — use VademecumDrugContent
/// for the resolved result returned to UI callers.
class _DrugEntry {
  final List<String> aliases;
  final String? rxcui;
  final String labelEs;
  final String labelEn;
  final String labelZh;
  final VademecumKind kind;
  final String confidence;
  final String summaryEs;
  final String summaryEn;
  final String summaryZh;
  final String? notesEs;
  final String? notesEn;
  final String? notesZh;
  final List<VademecumInteraction> interactions;

  _DrugEntry({
    required this.aliases,
    required this.rxcui,
    required this.labelEs,
    required this.labelEn,
    required this.labelZh,
    required this.kind,
    required this.confidence,
    required this.summaryEs,
    required this.summaryEn,
    required this.summaryZh,
    required this.notesEs,
    required this.notesEn,
    required this.notesZh,
    required this.interactions,
  });

  String label(VademecumLocale l) => switch (l) {
    VademecumLocale.es => labelEs,
    VademecumLocale.en => labelEn,
    VademecumLocale.zh => labelZh,
  };

  String summary(VademecumLocale l) => switch (l) {
    VademecumLocale.es => summaryEs,
    VademecumLocale.en => summaryEn,
    VademecumLocale.zh => summaryZh,
  };

  String? notes(VademecumLocale l) {
    final raw = switch (l) {
      VademecumLocale.es => notesEs,
      VademecumLocale.en => notesEn,
      VademecumLocale.zh => notesZh,
    };
    final trimmed = raw?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  factory _DrugEntry.fromMap(Map<String, dynamic> m) => _DrugEntry(
    aliases: List<String>.from(m['aliases'] as List? ?? []),
    rxcui: m['rxcui'] as String?,
    labelEs: m['label'] as String? ?? '',
    labelEn: m['label_en'] as String? ?? '',
    labelZh: m['label_zh'] as String? ?? '',
    kind: VademecumKind.parse(m['kind'] as String?),
    confidence: m['confidence'] as String? ?? 'high',
    summaryEs: m['summary_es'] as String? ?? '',
    summaryEn: m['summary_en'] as String? ?? '',
    summaryZh: m['summary_zh'] as String? ?? '',
    notesEs: m['notes'] as String?,
    notesEn: m['notes_en'] as String?,
    notesZh: m['notes_zh'] as String?,
    interactions: ((m['interactions'] as List?) ?? const [])
        .map(
          (x) =>
              VademecumInteraction.fromMap(Map<String, dynamic>.from(x as Map)),
        )
        .toList(),
  );
}

/// Result of resolving a MedicationDef against the vademecum.
///
/// `source` indicates where the body content came from:
///   - "local"      → summary + notes from drug_codes_v2.json
///   - "medlineplus" → summary from MedlinePlus Connect API
///   - "none"       → no content available; UI should show the "no info"
///                    state with the reason in `noContentReason`
class VademecumDrugContent {
  final String resolvedLabel;
  final VademecumKind kind;
  final String confidence;
  final String? summary;
  final String? notes;
  final String? externalLink;
  final String source;
  final String? noContentReason;
  final String? rxcui;

  VademecumDrugContent({
    required this.resolvedLabel,
    required this.kind,
    required this.confidence,
    this.summary,
    this.notes,
    this.externalLink,
    required this.source,
    this.noContentReason,
    this.rxcui,
  });

  bool get hasContent => summary != null && summary!.isNotEmpty;
  bool get isMediumConfidence => confidence == 'medium';
}

/// Interaction surfaced between a target med and another med in the
/// active botiquín.
class DetectedInteraction {
  final MedicationDef other;
  final InteractionSeverity severity;
  final String description;

  DetectedInteraction({
    required this.other,
    required this.severity,
    required this.description,
  });
}

class VademecumService {
  static const _base = 'https://connect.medlineplus.gov/service';
  static const _cacheDays = 7;

  List<_ConditionMapping>? _conditionMappings;
  List<_DrugEntry>? _drugEntries;

  // ---------------------------------------------------------------------------
  // CONDITION SIDE (unchanged from MedlinePlusService — kept verbatim
  // because the report builder and condition_info_sheet still use it)
  // ---------------------------------------------------------------------------

  Future<void> _ensureConditionsLoaded() async {
    if (_conditionMappings != null) return;
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/condition_codes.json',
      );
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final list = (data['mappings'] as List?) ?? [];
      _conditionMappings = list
          .map((m) => _ConditionMapping.fromMap(m as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('VademecumService._ensureConditionsLoaded: $e\n$st');
      _conditionMappings = [];
    }
    debugPrint(
      'VademecumService: loaded ${_conditionMappings?.length ?? 0} mappings',
    );
  }

  Future<_ConditionMapping?> resolveCondition(String userInput) async {
    await _ensureConditionsLoaded();
    if (_conditionMappings == null || _conditionMappings!.isEmpty) return null;
    final norm = userInput.trim().toLowerCase();
    for (final m in _conditionMappings!) {
      for (final alias in m.aliases) {
        if (alias.toLowerCase() == norm) return m;
      }
    }
    if (norm.length > 3) {
      for (final m in _conditionMappings!) {
        for (final alias in m.aliases) {
          if (norm.contains(alias.toLowerCase()) ||
              alias.toLowerCase().contains(norm))
            return m;
        }
      }
    }
    return null;
  }

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
      } catch (e) {
        debugPrint('VademecumService.getContent cache decode error: $e');
      }
    }
    MedlinePlusContent? content = await _fetchConditionFromApi(icd10);
    if (content == null && icd10.contains('.')) {
      final parts = icd10.split('.');
      if (parts[1].length > 1) {
        content = await _fetchConditionFromApi(
          '${parts[0]}.${parts[1].substring(0, 1)}',
        );
      }
    }
    if (content == null && icd10.contains('.')) {
      content = await _fetchConditionFromApi(icd10.split('.')[0]);
    }
    if (content != null) {
      final finalContent = MedlinePlusContent(
        icd10: icd10,
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

  Future<MedlinePlusContent?> _fetchConditionFromApi(String queryIcd) async {
    final url = Uri.parse(
      '$_base?'
      'mainSearchCriteria.v.cs=2.16.840.1.113883.6.90'
      '&mainSearchCriteria.v.c=${Uri.encodeComponent(queryIcd)}'
      '&informationRecipient.languageCode.c=es'
      '&knowledgeResponseType=application/json',
    );
    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        debugPrint(
          'VademecumService._fetchConditionFromApi: HTTP ${resp.statusCode} for $queryIcd',
        );
        return null;
      }
      return _parseConditionResponse(resp.body, queryIcd);
    } catch (e) {
      debugPrint(
        'VademecumService._fetchConditionFromApi error ($queryIcd): $e',
      );
      return null;
    }
  }

  MedlinePlusContent? _parseConditionResponse(String body, String queryIcd) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
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
    } catch (e) {
      debugPrint('VademecumService._parseConditionResponse error: $e');
      return null;
    }
  }

  String _stripHtml(String html) => html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<p\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');

  // ---------------------------------------------------------------------------
  // DRUG SIDE — local-first cascade with MedlinePlus fallback
  // ---------------------------------------------------------------------------

  Future<void> _ensureDrugsLoaded() async {
    if (_drugEntries != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/drug_codes.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final list = (data['mappings'] as List?) ?? [];
      _drugEntries = list
          .map((m) => _DrugEntry.fromMap(m as Map<String, dynamic>))
          .toList();
      debugPrint(
        'VademecumService: loaded ${_drugEntries!.length} drug entries',
      );
    } catch (e, st) {
      debugPrint('VademecumService._ensureDrugsLoaded: $e\n$st');
      _drugEntries = [];
    }
  }

  /// Resolve a string input to a drug entry. Same matching strategy as
  /// before: exact alias match first, then a loose contains-match guarded
  /// by length > 3 to avoid spurious short matches.
  Future<_DrugEntry?> _resolveDrugString(String input) async {
    await _ensureDrugsLoaded();
    if (_drugEntries == null || _drugEntries!.isEmpty) return null;
    final norm = input.trim().toLowerCase();
    if (norm.isEmpty) return null;
    for (final e in _drugEntries!) {
      for (final alias in e.aliases) {
        if (alias.toLowerCase() == norm) return e;
      }
    }
    if (norm.length > 3) {
      for (final e in _drugEntries!) {
        for (final alias in e.aliases) {
          if (norm.contains(alias.toLowerCase()) ||
              alias.toLowerCase().contains(norm)) {
            return e;
          }
        }
      }
    }
    return null;
  }

  /// Resolution cascade for a MedicationDef: try activeIngredient first,
  /// then display name. Returns the matched entry or null.
  Future<_DrugEntry?> _resolveMedicationEntry(MedicationDef med) async {
    final ai = med.activeIngredient?.trim();
    if (ai != null && ai.isNotEmpty) {
      final byIngredient = await _resolveDrugString(ai);
      if (byIngredient != null) return byIngredient;
    }
    return _resolveDrugString(med.name);
  }

  /// Public alternative for callers that only have a raw MedicationDef
  /// and want the resolved kind. Returns null if unknown.
  Future<VademecumKind?> getKindFor(MedicationDef med) async {
    final entry = await _resolveMedicationEntry(med);
    return entry?.kind;
  }

  /// Resolve full content for a med. Cascade:
  ///   1. Try to match med against local drug_codes.json.
  ///   2. If matched and local entry has summary content → return it.
  ///   3. If matched and entry has rxcui but no local summary →
  ///      query MedlinePlus.
  ///   4. If matched, no rxcui, no summary → return notes-only or
  ///      no-content with kind-specific reason.
  ///   5. If not matched at all → return no-content "unmapped".
  Future<VademecumDrugContent> getDrugContent(
    MedicationDef med,
    VademecumLocale locale,
  ) async {
    final entry = await _resolveMedicationEntry(med);

    if (entry == null) {
      return VademecumDrugContent(
        resolvedLabel: med.name,
        kind: VademecumKind.medication,
        confidence: 'low',
        source: 'none',
        noContentReason: 'unmapped',
      );
    }

    final summary = entry.summary(locale).trim();
    final notes = entry.notes(locale);

    // Step 2: local content available → return it without hitting the
    // network. Faster, works offline, and removes the CORS-prone path
    // for the meds Paulina actually uses.
    if (summary.isNotEmpty) {
      return VademecumDrugContent(
        resolvedLabel: entry.label(locale),
        kind: entry.kind,
        confidence: entry.confidence,
        summary: summary,
        notes: notes,
        source: 'local',
        rxcui: entry.rxcui,
      );
    }

    // Step 3: entry has rxcui and is a medication → try MedlinePlus.
    if (entry.rxcui != null && entry.kind == VademecumKind.medication) {
      final mpContent = await _getDrugInfoFromMedlinePlus(entry.rxcui!, locale);
      if (mpContent != null) {
        return VademecumDrugContent(
          resolvedLabel: entry.label(locale),
          kind: entry.kind,
          confidence: entry.confidence,
          summary: mpContent.summary,
          notes: notes,
          externalLink: mpContent.link,
          source: 'medlineplus',
          rxcui: entry.rxcui,
        );
      }
    }

    // Step 4: matched but no summary anywhere. Reason depends on kind.
    final reason = switch (entry.kind) {
      VademecumKind.supplement => 'supplement_no_content',
      VademecumKind.herbal => 'herbal_no_content',
      VademecumKind.medication =>
        entry.rxcui != null ? 'medlineplus_empty' : 'unmapped',
    };
    return VademecumDrugContent(
      resolvedLabel: entry.label(locale),
      kind: entry.kind,
      confidence: entry.confidence,
      notes: notes,
      source: 'none',
      noContentReason: reason,
      rxcui: entry.rxcui,
    );
  }

  Future<MedlinePlusDrugContent?> _getDrugInfoFromMedlinePlus(
    String rxcui,
    VademecumLocale locale,
  ) async {
    final box = Hive.box('zebraBox');
    final lang = locale == VademecumLocale.en ? 'en' : 'es';
    final cacheKey = 'medlineplus_drug:$lang:$rxcui';
    final cached = box.get(cacheKey) as String?;
    if (cached != null) {
      try {
        final m = jsonDecode(cached) as Map<String, dynamic>;
        final fetchedAt = DateTime.parse(m['fetchedAt'] as String);
        if (DateTime.now().difference(fetchedAt).inDays < _cacheDays) {
          return MedlinePlusDrugContent.fromMap(m);
        }
      } catch (e) {
        debugPrint(
          'VademecumService._getDrugInfoFromMedlinePlus cache error: $e',
        );
      }
    }
    final content = await _fetchDrugFromApi(rxcui, lang);
    if (content != null) {
      await box.put(cacheKey, jsonEncode(content.toMap()));
    }
    return content;
  }

  Future<MedlinePlusDrugContent?> _fetchDrugFromApi(
    String rxcui,
    String lang,
  ) async {
    final url = Uri.parse(
      '$_base?'
      'mainSearchCriteria.v.cs=2.16.840.1.113883.6.88'
      '&mainSearchCriteria.v.c=${Uri.encodeComponent(rxcui)}'
      '&informationRecipient.languageCode.c=$lang'
      '&knowledgeResponseType=application/json',
    );
    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        debugPrint(
          'VademecumService._fetchDrugFromApi: HTTP ${resp.statusCode} for rxcui=$rxcui lang=$lang',
        );
        return null;
      }
      return _parseDrugResponse(resp.body, rxcui);
    } catch (e) {
      debugPrint(
        'VademecumService._fetchDrugFromApi error (rxcui=$rxcui lang=$lang): $e',
      );
      return null;
    }
  }

  MedlinePlusDrugContent? _parseDrugResponse(String body, String rxcui) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
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
      return MedlinePlusDrugContent(
        rxcui: rxcui,
        title: title.trim(),
        summary: _stripHtml(summary).trim(),
        link: link,
        fetchedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('VademecumService._parseDrugResponse error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // INTERACTION DETECTION — cross-references the active botiquín
  // ---------------------------------------------------------------------------

  /// Detect declared interactions between `target` and any other med in
  /// `botiquin`. Bidirectional: a pair declared on duloxetine pointing to
  /// dextromethorphan will surface whether you open duloxetine OR
  /// dextromethorphan.
  ///
  /// `target` is excluded from `botiquin` for matching (a med doesn't
  /// interact with itself). Returns a list sorted by severity desc.
  Future<List<DetectedInteraction>> detectInteractions(
    MedicationDef target,
    List<MedicationDef> botiquin,
    VademecumLocale locale,
  ) async {
    await _ensureDrugsLoaded();
    if (_drugEntries == null || _drugEntries!.isEmpty) return [];

    final targetEntry = await _resolveMedicationEntry(target);
    if (targetEntry == null) return [];

    final others = botiquin.where((m) => m.id != target.id).toList();
    if (others.isEmpty) return [];

    final detected = <DetectedInteraction>[];
    final seen = <String>{}; // dedup by (other.id + severity + description)

    void add(MedicationDef other, VademecumInteraction inter) {
      final key = '${other.id}|${inter.severity.name}|${inter.descriptionEs}';
      if (seen.contains(key)) return;
      seen.add(key);
      detected.add(
        DetectedInteraction(
          other: other,
          severity: inter.severity,
          description: inter.description(locale),
        ),
      );
    }

    // Direction 1: interactions declared on target → look up which
    // botiquin meds match the `with` alias.
    for (final inter in targetEntry.interactions) {
      final withNorm = inter.withAlias.toLowerCase();
      for (final other in others) {
        if (_medMatchesAlias(other, withNorm)) {
          add(other, inter);
        }
      }
    }

    // Direction 2: interactions declared on OTHER botiquin meds → look
    // up if their `with` alias points back to target.
    for (final other in others) {
      final otherEntry = await _resolveMedicationEntry(other);
      if (otherEntry == null) continue;
      for (final inter in otherEntry.interactions) {
        final withNorm = inter.withAlias.toLowerCase();
        if (_medMatchesAlias(target, withNorm) ||
            _entryHasAlias(targetEntry, withNorm)) {
          add(other, inter);
        }
      }
    }

    detected.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return detected;
  }

  bool _medMatchesAlias(MedicationDef med, String aliasLower) {
    final name = med.name.trim().toLowerCase();
    if (name == aliasLower ||
        name.contains(aliasLower) ||
        aliasLower.contains(name)) {
      return true;
    }
    final ai = med.activeIngredient?.trim().toLowerCase();
    if (ai != null && ai.isNotEmpty) {
      if (ai == aliasLower ||
          ai.contains(aliasLower) ||
          aliasLower.contains(ai)) {
        return true;
      }
    }
    return false;
  }

  bool _entryHasAlias(_DrugEntry entry, String aliasLower) {
    for (final a in entry.aliases) {
      if (a.toLowerCase() == aliasLower) return true;
    }
    return false;
  }
}

/// Backwards-compat alias. Existing imports of `MedlinePlusService` keep
/// working until the migration sprint cleans up call sites. New code
/// should use `VademecumService` directly.
typedef MedlinePlusService = VademecumService;

// =============================================================================
// Condition mapping (unchanged from previous version)
// =============================================================================

class _ConditionMapping {
  final List<String> aliases;
  final String? icd10;
  final String label;

  _ConditionMapping({
    required this.aliases,
    required this.icd10,
    required this.label,
  });

  factory _ConditionMapping.fromMap(Map<String, dynamic> m) =>
      _ConditionMapping(
        aliases: List<String>.from(m['aliases'] as List? ?? []),
        icd10: m['icd10'] as String?,
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

  factory MedlinePlusContent.fromMap(Map<String, dynamic> m) =>
      MedlinePlusContent(
        icd10: m['icd10'] as String,
        title: m['title'] as String,
        summary: m['summary'] as String,
        link: m['link'] as String?,
        fetchedAt: DateTime.parse(m['fetchedAt'] as String),
      );
}

class MedlinePlusDrugContent {
  final String rxcui;
  final String title;
  final String summary;
  final String? link;
  final DateTime fetchedAt;

  MedlinePlusDrugContent({
    required this.rxcui,
    required this.title,
    required this.summary,
    this.link,
    required this.fetchedAt,
  });

  Map<String, dynamic> toMap() => {
    'rxcui': rxcui,
    'title': title,
    'summary': summary,
    'link': link,
    'fetchedAt': fetchedAt.toIso8601String(),
  };

  factory MedlinePlusDrugContent.fromMap(Map<String, dynamic> m) =>
      MedlinePlusDrugContent(
        rxcui: m['rxcui'] as String,
        title: m['title'] as String,
        summary: m['summary'] as String,
        link: m['link'] as String?,
        fetchedAt: DateTime.parse(m['fetchedAt'] as String),
      );
}
