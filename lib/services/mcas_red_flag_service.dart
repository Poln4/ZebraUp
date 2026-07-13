// Sprint E.C — MCAS red flag detection service.
//
// Surfaces the red flag markers captured in the MCAS detail sheet
// as a list for the advisory dialog. Matches the signature convention
// of detectHeadacheRedFlags / detectFatigueRedFlags /
// detectAbdominalRedFlags so the sintomas_tab invocation stays
// consistent across domains.
//
// v1: pass-through — every explicit MCASRedFlag captured in the sheet
// surfaces. No inference logic yet.
//
// Future extensions (documented for the next iteration):
//   • Infer anaphylaxis pattern from combined reaction kinds
//     (respiratory + cardiovascular + immediate onset) even when no
//     explicit red flag was marked. Weiler CR et al. 2019 AAAAI
//     consensus supports this inference for chip-level detection.
//   • Elevate severity when severityIndex >= 3 combined with
//     specific reaction combinations (e.g., angioedema + severity 4
//     → surface tongueSwelling implicitly).
//   • Suppress duplicates via Set semantics when v2 inference is
//     added (already using Set literal below for that reason).

import '../models/mcas.dart';

/// Returns the list of MCASRedFlag markers to surface as advisory
/// after a SymptomEvent with an mcasDetail is saved.
///
/// Empty list = no advisory needed. Caller should treat empty as
/// no-op.
List<MCASRedFlag> detectMCASRedFlags({
  required MCASDetail detail,
  int? severityIndex,
}) {
  final surfaced = <MCASRedFlag>{...detail.redFlags};
  return surfaced.toList();
}
