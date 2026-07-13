// Sprint B.A + B.B — Beta access + research consent state.
//
// Persisted globally in Hive box "betaAccessBox" under key "state".
// NOT per-profile: one access grant unlocks the device for all
// profiles created within it. Simpler onboarding for caregivers
// and families managing multiple profiles.
//
// Fields:
//   • accessGranted — user entered a valid beta code
//   • grantedAt — when the code was accepted
//   • researchConsentAccepted — user accepted the research disclaimer
//   • researchConsentAt — when accepted (null if declined or not yet)
//   • lastFeedbackPromptAt — B.C reserved: when the last feedback
//     banner appeared
//   • feedbackPromptEnabled — B.C reserved: user preference for
//     the weekly feedback banner

class BetaAccessState {
  bool accessGranted;
  DateTime? grantedAt;
  bool researchConsentAccepted;
  DateTime? researchConsentAt;
  DateTime? lastFeedbackPromptAt;
  bool feedbackPromptEnabled;

  BetaAccessState({
    this.accessGranted = false,
    this.grantedAt,
    this.researchConsentAccepted = false,
    this.researchConsentAt,
    this.lastFeedbackPromptAt,
    this.feedbackPromptEnabled = true,
  });

  /// Empty starting state — nothing granted or accepted yet.
  factory BetaAccessState.empty() => BetaAccessState();

  Map<String, dynamic> toMap() => {
    'accessGranted': accessGranted,
    if (grantedAt != null) 'grantedAt': grantedAt!.toIso8601String(),
    'researchConsentAccepted': researchConsentAccepted,
    if (researchConsentAt != null)
      'researchConsentAt': researchConsentAt!.toIso8601String(),
    if (lastFeedbackPromptAt != null)
      'lastFeedbackPromptAt': lastFeedbackPromptAt!.toIso8601String(),
    'feedbackPromptEnabled': feedbackPromptEnabled,
  };

  factory BetaAccessState.fromMap(Map<String, dynamic> map) {
    DateTime? tryParse(dynamic v) => v is String ? DateTime.tryParse(v) : null;
    return BetaAccessState(
      accessGranted: map['accessGranted'] == true,
      grantedAt: tryParse(map['grantedAt']),
      researchConsentAccepted: map['researchConsentAccepted'] == true,
      researchConsentAt: tryParse(map['researchConsentAt']),
      lastFeedbackPromptAt: tryParse(map['lastFeedbackPromptAt']),
      feedbackPromptEnabled: map['feedbackPromptEnabled'] != false,
    );
  }
}
