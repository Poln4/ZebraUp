// C.4 — Symptom definitions service
//
// Loads assets/symptom_definitions.json once and provides locale-aware
// lookups for symptom master definitions and chip definitions used in
// the symptom-detail layer system. The JSON is editorial content
// curated outside of code; this service is intentionally thin.
//
// Usage:
//   final svc = SymptomDefinitionsService.instance;
//   await svc.ensureLoaded();
//   final label = svc.getChipLabel('headache', 'location', 'unilateral', 'es');
//
// For per-symptom typed access (e.g. iterating headache groups in
// order), see the symptom-specific detail model files like
// `lib/models/headache_detail.dart`.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SymptomDefinitionsService {
  SymptomDefinitionsService._();
  static final SymptomDefinitionsService instance =
      SymptomDefinitionsService._();

  Map<String, dynamic>? _data;

  /// Idempotent loader. Safe to call multiple times — only reads asset
  /// once. Errors fall back silently to an empty map so lookups return
  /// null instead of crashing the UI.
  Future<void> ensureLoaded() async {
    if (_data != null) return;
    try {
      final jsonStr = await rootBundle
          .loadString('assets/symptom_definitions.json');
      _data = jsonDecode(jsonStr) as Map<String, dynamic>;
      debugPrint('SymptomDefinitionsService: loaded '
          '${_data!.keys.where((k) => !k.startsWith('_')).length} symptoms');
    } catch (e, st) {
      debugPrint('SymptomDefinitionsService.ensureLoaded: $e\n$st');
      _data = {};
    }
  }

  bool get isLoaded => _data != null;

  /// Pick the language suffix for a label/def key based on a locale
  /// string. Defaults to 'es' for unknown locales.
  static String _langSuffixFor(String localeCode) {
    final c = localeCode.toLowerCase();
    if (c.startsWith('zh')) return 'zh';
    if (c.startsWith('en')) return 'en';
    return 'es';
  }

  /// Generic string lookup with fallback chain: requested locale → en
  /// → es → null.
  String? _localizedString(
      Map<String, dynamic> source, String baseKey, String localeCode) {
    final primary = _langSuffixFor(localeCode);
    final order = [primary, 'en', 'es'].toSet().toList();
    for (final lang in order) {
      final v = source['${baseKey}_$lang'];
      if (v is String && v.trim().isNotEmpty) return v;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Symptom master lookups
  // ---------------------------------------------------------------------------

  Map<String, dynamic>? _symptomNode(String symptomKey) {
    if (_data == null) return null;
    final node = _data![symptomKey];
    return node is Map<String, dynamic> ? node : null;
  }

  Map<String, dynamic>? _masterNode(String symptomKey) {
    final sym = _symptomNode(symptomKey);
    if (sym == null) return null;
    final master = sym['master'];
    return master is Map<String, dynamic> ? master : null;
  }

  String? getMasterLabel(String symptomKey, String localeCode) {
    final m = _masterNode(symptomKey);
    if (m == null) return null;
    return _localizedString(m, 'label', localeCode);
  }

  String? getMasterDefinition(String symptomKey, String localeCode) {
    final m = _masterNode(symptomKey);
    if (m == null) return null;
    return _localizedString(m, 'definition', localeCode);
  }

  /// List of aliases (user-input strings) that match this symptom key.
  /// Used by matchesSymptomKey for fuzzy detection.
  List<String> getAliases(String symptomKey) {
    final sym = _symptomNode(symptomKey);
    if (sym == null) return const [];
    final a = sym['aliases'];
    if (a is! List) return const [];
    return a.whereType<String>().toList();
  }

  /// Case-insensitive alias match. Returns true if `userInput` matches
  /// any alias for `symptomKey` either exactly or via contains-match
  /// (guarded by length > 3 to avoid spurious short matches).
  ///
  /// Same matching strategy as VademecumService.resolveCondition, so
  /// behaviour is consistent across the app.
  bool matchesSymptomKey(String userInput, String symptomKey) {
    final norm = userInput.trim().toLowerCase();
    if (norm.isEmpty) return false;
    final aliases = getAliases(symptomKey);
    for (final a in aliases) {
      if (a.toLowerCase() == norm) return true;
    }
    if (norm.length > 3) {
      for (final a in aliases) {
        final al = a.toLowerCase();
        if (norm.contains(al) || al.contains(norm)) return true;
      }
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // D.2 — Alias variant detection for progressive disclosure semántico
  // ---------------------------------------------------------------------------

  /// Returns a semantic-variant tag for [userInput] when [symptomKey]
  /// has multiple semantic alias clusters. Used by the D.2 abdominal
  /// detail sheet to pre-mark chips based on which term the user typed.
  ///
  /// Currently only 'abdominal_pain' has variants:
  ///   - 'pain'     : dolor, cólico, retortijón, cramps, ...
  ///   - 'bloating' : hinchazón, distensión, bloating, ...
  ///   - 'gas'      : gases, pedos, peos, flatulencia, gas, ...
  ///
  /// Returns null for symptoms without variants (headache, fatigue) or
  /// when no variant matches. Check order is bloating → gas → pain so
  /// specific variants win over the generic pain cluster.
  ///
  /// Future symptoms with variants extend the mapping here. If the
  /// number of variant-aware symptoms grows past 3-4, migrate to
  /// JSON-driven variant markers instead of hard-coded lists.
  String? detectAliasVariant(String userInput, String symptomKey) {
    if (symptomKey != 'abdominal_pain') return null;
    final norm = userInput.trim().toLowerCase();
    if (norm.isEmpty) return null;

    for (final a in _abdominalBloatingAliases) {
      if (norm == a || norm.contains(a) || a.contains(norm)) {
        return 'bloating';
      }
    }
    for (final a in _abdominalGasAliases) {
      if (norm == a || norm.contains(a) || a.contains(norm)) {
        return 'gas';
      }
    }
    for (final a in _abdominalPainAliases) {
      if (norm == a || norm.contains(a) || a.contains(norm)) {
        return 'pain';
      }
    }
    return null;
  }

  // Variant clusters for abdominal_pain — lowercase for direct comparison.
  static const _abdominalPainAliases = <String>[
    // es
    'dolor abdominal', 'dolor de estómago', 'dolor de guata',
    'dolor de panza', 'dolor de barriga', 'dolor de vientre',
    'cólico', 'cólicos', 'retortijón', 'retortijones',
    // en
    'abdominal pain', 'stomach pain', 'belly pain', 'tummy pain',
    'cramps', 'cramping', 'gut pain',
    // zh
    '腹痛', '肚子痛', '胃痛',
  ];

  static const _abdominalBloatingAliases = <String>[
    // es
    'hinchazón', 'hinchazón abdominal', 'distensión',
    'distensión abdominal', 'panza hinchada', 'guata hinchada',
    // en
    'bloating', 'abdominal distension',
    // zh
    '腹脹', '腹部脹氣',
  ];

  static const _abdominalGasAliases = <String>[
    // es
    'gases', 'pedos', 'peos', 'flatulencia', 'flatulencias',
    // en
    'gas', 'farting', 'flatulence',
    // zh
    '放屁', '排氣', '脹氣',
  ];

  // ---------------------------------------------------------------------------
  // Group + chip lookups
  // ---------------------------------------------------------------------------

  Map<String, dynamic>? _groupNode(String symptomKey, String groupKey) {
    final sym = _symptomNode(symptomKey);
    if (sym == null) return null;
    final groups = sym['groups'];
    if (groups is! Map<String, dynamic>) return null;
    final g = groups[groupKey];
    return g is Map<String, dynamic> ? g : null;
  }

  String? getGroupHeader(
      String symptomKey, String groupKey, String localeCode) {
    final g = _groupNode(symptomKey, groupKey);
    if (g == null) return null;
    return _localizedString(g, 'header', localeCode);
  }

  /// 'single_select' or 'multi_select'. Returns null if group missing.
  String? getGroupKind(String symptomKey, String groupKey) {
    final g = _groupNode(symptomKey, groupKey);
    if (g == null) return null;
    final k = g['kind'];
    return k is String ? k : null;
  }

  Map<String, dynamic>? _chipNode(
      String symptomKey, String groupKey, String chipKey) {
    final g = _groupNode(symptomKey, groupKey);
    if (g == null) return null;
    final chips = g['chips'];
    if (chips is! Map<String, dynamic>) return null;
    final c = chips[chipKey];
    return c is Map<String, dynamic> ? c : null;
  }

  String? getChipLabel(String symptomKey, String groupKey, String chipKey,
      String localeCode) {
    final c = _chipNode(symptomKey, groupKey, chipKey);
    if (c == null) return null;
    return _localizedString(c, 'label', localeCode);
  }

  String? getChipDefinition(String symptomKey, String groupKey,
      String chipKey, String localeCode) {
    final c = _chipNode(symptomKey, groupKey, chipKey);
    if (c == null) return null;
    return _localizedString(c, 'def', localeCode);
  }

  /// Ordered list of chip keys in a group (preserves JSON insertion
  /// order, which is the intended UI display order).
  List<String> getChipKeysInOrder(String symptomKey, String groupKey) {
    final g = _groupNode(symptomKey, groupKey);
    if (g == null) return const [];
    final chips = g['chips'];
    if (chips is! Map<String, dynamic>) return const [];
    return chips.keys.toList();
  }

  /// Ordered list of group keys for a symptom (preserves JSON insertion
  /// order — the intended UI display order: location → quality →
  /// accompaniments → postural_pattern → onset).
  List<String> getGroupKeysInOrder(String symptomKey) {
    final sym = _symptomNode(symptomKey);
    if (sym == null) return const [];
    final groups = sym['groups'];
    if (groups is! Map<String, dynamic>) return const [];
    return groups.keys.toList();
  }
}
