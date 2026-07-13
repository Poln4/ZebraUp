// Sprint P.A — Profile transient state subsection.
//
// Groups state that changes during a session or over short spans,
// and doesn't fit as history (event stream), catalog (user-curated
// content), or identity.
//
// Currently home for:
//   • pacingDays — Set of ISO date strings (YYYY-MM-DD) the user
//     marked as recovery days. Membership is a boolean per day.
//   • flare — FlareState? tracking active crisis-mode session.
//     Null when not in flare mode; instantiated when the user (or
//     the auto-suggestion pattern) activates flare mode.
//
// Future home for:
//   • Multi-observer permission grants (see
//     docs/design_decisions/multi_observer_profiles.md)
//   • Energy budget snapshot (once we implement PacePoints-style
//     tracking)
//   • Last-seen alert timestamps to prevent spam re-firing
//
// Not for: user-tunable preferences (see ProfileSettings) or
// long-lived history (kept on Profile as List<XxxEvent>).

class FlareState {
  /// When flare mode was activated. Immutable — flare "sessions" have
  /// a fixed start; if the user reactivates after deactivating, a new
  /// FlareState is created with a new startedAt.
  final DateTime startedAt;

  /// Optional free-text field the user can drop notes into during a
  /// flare. Not analyzed for patterns — just a dumping ground so the
  /// user can offload cognitive weight without navigating menus.
  String? notes;

  /// How many times the "¿seguís en crisis?" prompt has fired for
  /// this flare session. Incremented on each 48h check-in.
  int promptCount;

  /// When the most recent 48h prompt fired. Null if never prompted
  /// yet. Used to compute whether the next prompt is due.
  DateTime? lastPromptAt;

  FlareState({
    required this.startedAt,
    this.notes,
    this.promptCount = 0,
    this.lastPromptAt,
  });

  /// Time since flare mode was activated.
  Duration get duration => DateTime.now().difference(startedAt);

  /// True when the next 48h check-in prompt is due.
  bool get isPromptDue {
    final reference = lastPromptAt ?? startedAt;
    return DateTime.now().difference(reference) >= const Duration(hours: 48);
  }

  Map<String, dynamic> toMap() => {
    'startedAt': startedAt.toIso8601String(),
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'promptCount': promptCount,
    if (lastPromptAt != null) 'lastPromptAt': lastPromptAt!.toIso8601String(),
  };

  factory FlareState.fromMap(Map<String, dynamic> map) {
    final startedRaw = map['startedAt'];
    final lastPromptRaw = map['lastPromptAt'];
    return FlareState(
      startedAt: startedRaw is String
          ? (DateTime.tryParse(startedRaw) ?? DateTime.now())
          : DateTime.now(),
      notes: map['notes'] is String ? map['notes'] as String : null,
      promptCount: (map['promptCount'] as num?)?.toInt() ?? 0,
      lastPromptAt: lastPromptRaw is String
          ? DateTime.tryParse(lastPromptRaw)
          : null,
    );
  }
}

class ProfileState {
  Set<String> pacingDays;
  FlareState? flare;

  /// Sprint G.E — cooldown timestamp for the auto-suggestion
  /// banner. Set to DateTime.now() when the user dismisses the
  /// '¿estás pasando un mal día?' prompt. The banner won't
  /// re-appear until 24 hours have passed. Null = never
  /// dismissed.
  DateTime? flareSuggestionDismissedAt;

  ProfileState({
    Set<String>? pacingDays,
    this.flare,
    this.flareSuggestionDismissedAt,
  }) : pacingDays = pacingDays ?? <String>{};

  /// True when a flare session is currently active.
  bool get isInFlare => flare != null;

  /// Sprint G.E — true when the suggestion banner is in
  /// cooldown (user dismissed it within the last 24 hours).
  bool get isSuggestionInCooldown {
    final dismissed = flareSuggestionDismissedAt;
    if (dismissed == null) return false;
    return DateTime.now().difference(dismissed) < const Duration(hours: 24);
  }

  Map<String, dynamic> toMap() => {
    'pacingDays': pacingDays.toList(),
    if (flare != null) 'flare': flare!.toMap(),
    if (flareSuggestionDismissedAt != null)
      'flareSuggestionDismissedAt': flareSuggestionDismissedAt!
          .toIso8601String(),
  };

  factory ProfileState.fromMap(Map<String, dynamic> map) {
    final pacingRaw = map['pacingDays'];
    final flareRaw = map['flare'];
    final dismissedRaw = map['flareSuggestionDismissedAt'];
    return ProfileState(
      pacingDays: pacingRaw is List
          ? Set<String>.from(pacingRaw.whereType<String>())
          : <String>{},
      flare: flareRaw is Map
          ? FlareState.fromMap(Map<String, dynamic>.from(flareRaw))
          : null,
      flareSuggestionDismissedAt: dismissedRaw is String
          ? DateTime.tryParse(dismissedRaw)
          : null,
    );
  }
}
