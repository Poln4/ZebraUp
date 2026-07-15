// Shared severity tier for symptom-detail red flags (headache, fatigue,
// abdominal, and any future detail layer). Consolidated from three
// duplicate per-symptom enums — see CLAUDE.md "Deuda técnica conocida".

enum RedFlagSeverity {
  /// Informational. Suggests medical follow-up if pattern repeats.
  advisory,

  /// Possible emergency. UI should make it visually distinct and
  /// include explicit "seek emergency care" guidance.
  urgent,
}
