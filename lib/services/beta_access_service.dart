// Sprint B.A + B.B — Beta access service.
//
// Wraps Hive.box('betaAccessBox') with typed getters/setters.
// The box is opened in main() before runApp; this service assumes
// it's ready. Under key 'state' we store the BetaAccessState map.
//
// Access code is hardcoded here. To rotate for a new beta cycle:
// 1. Change BetaAccessService.accessCode constant
// 2. Rebuild + redeploy the app
// 3. Existing users who already unlocked stay unlocked
//    (accessGranted persists in Hive; a new code doesn't re-lock them)

import 'package:hive/hive.dart';
import '../models/beta_access_state.dart';

class BetaAccessService {
  /// The current beta access code. Case-insensitive comparison.
  /// See file docstring for rotation instructions.
  static const String accessCode = 'cebrasARRIBAch';

  /// Public URL where prospective users can request a code.
  /// TODO: replace with the actual Google Form URL when B.D lands.
  static const String requestCodeUrl =
      'https://zebraup-beta.netlify.app';

  /// Sprint B.C - Public URL for the weekly feedback form.
  /// TODO: replace with the actual Google Form URL.
  static const String feedbackFormUrl =
      'https://forms.gle/f7EivvudBmegnXj38';

  /// Public URL for the follow-up questionnaire, surfaced as a quick-access
  /// link from Ajustes → Acerca de. Spanish only (Paulina, 2026-07-18) —
  /// gate display to the Spanish locale at the call site, don't translate
  /// the form itself.
  static const String followUpQuestionnaireUrl =
      'https://forms.gle/jfwxwp4QvTq1JNEW9';

  /// ZebraUp's Bluesky profile, surfaced from Ajustes → Acerca de.
  /// Unlike followUpQuestionnaireUrl, not locale-gated — a social presence
  /// link is relevant regardless of app language (Paulina, 2026-07-18).
  static const String blueskyUrl =
      'https://bsky.app/profile/zebraup.bsky.social';

  static Box get _box => Hive.box('betaAccessBox');
  static const String _stateKey = 'state';

  /// Load the persisted BetaAccessState. Returns empty state if
  /// nothing is stored yet (fresh install).
  static BetaAccessState loadState() {
    final raw = _box.get(_stateKey);
    if (raw is Map) {
      return BetaAccessState.fromMap(Map<String, dynamic>.from(raw));
    }
    return BetaAccessState.empty();
  }

  /// Persist the given BetaAccessState.
  static Future<void> saveState(BetaAccessState state) async {
    await _box.put(_stateKey, state.toMap());
  }

  /// Case-insensitive comparison against the current access code.
  static bool validateCode(String input) {
    return input.trim().toLowerCase() == accessCode.toLowerCase();
  }
}
