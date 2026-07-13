// Sprint P.A — Profile settings subsection.
//
// Groups user-tunable preferences that don't belong to identity,
// content, transient state, or history.
//
// Currently home for:
//   • optionalTrackers — per-feature enablement flags (e.g.
//     'mcas_detail', 'action_taken', 'headache_detail', etc.)
//     Keys are stable snake_case IDs; values are booleans.
//     Missing key = feature default (usually false).
//
// Future home for:
//   • theme preference (light/dark override, if we ever offer one)
//   • language preference (independent of device locale)
//   • notification preferences (once notifications ship)
//   • display density preferences
//
// Not for: things that vary during a session (see ProfileState),
// content the user creates (see history/catalog fields on Profile),
// or identity fields (name, id, conditions).
//
// If a future feature needs a non-boolean setting value (like a
// timestamp), add a dedicated field on ProfileSettings — do NOT
// change optionalTrackers to Map<String, dynamic>. That map's type
// discipline is a deliberate constraint.

class ProfileSettings {
  Map<String, bool> optionalTrackers;

  ProfileSettings({Map<String, bool>? optionalTrackers})
    : optionalTrackers = optionalTrackers ?? <String, bool>{};

  Map<String, dynamic> toMap() => {'optionalTrackers': optionalTrackers};

  factory ProfileSettings.fromMap(Map<String, dynamic> map) {
    final raw = map['optionalTrackers'];
    return ProfileSettings(
      optionalTrackers: raw is Map
          ? Map<String, bool>.from(
              raw.map((k, v) => MapEntry(k.toString(), v == true)),
            )
          : <String, bool>{},
    );
  }
}
