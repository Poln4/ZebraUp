// =============================================================================
// structural_taxonomy.dart — i18n extensions for the structural taxonomy.
//
// Phase F6.a (16-jun-2026): canonical pattern for taxonomy localization,
// mirroring the FeverSiteLocalization extension in
// lib/services/fever_analysis.dart.
//
// Stable IDs live in lib/models/models.dart:
//   - StructuralEventKind enum (6 kinds)
//   - kStructuralTaxonomy: kind → List<typeId> (28 types)
//   - kBodyZones: List<zoneId> (8 zones; F6.b expands this)
//
// Display labels are resolved at render time via the three extensions
// below, which switch on the stable ID and look up the matching ARB key.
// Unknown IDs fall back to the raw string (graceful degradation for
// legacy data that didn't migrate cleanly).
// =============================================================================

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
// 1. StructuralEventKind labels
// -----------------------------------------------------------------------------

extension StructuralEventKindLocalization on StructuralEventKind {
  String label(AppLocalizations l10n) => switch (this) {
        StructuralEventKind.joint => l10n.structKindJoint,
        StructuralEventKind.muscle => l10n.structKindMuscle,
        StructuralEventKind.tendon => l10n.structKindTendon,
        StructuralEventKind.ligament => l10n.structKindLigament,
        StructuralEventKind.softTissue => l10n.structKindSoftTissue,
        StructuralEventKind.nerve => l10n.structKindNerve,
      };
}

// -----------------------------------------------------------------------------
// 2. Structural type labels (extension on String, since types are stored as IDs)
// -----------------------------------------------------------------------------

/// Resolve a stable structural type ID (e.g. 'subluxation', 'muscle_strain')
/// to its localized display label. Unknown IDs return the raw string —
/// surfaces gracefully but visibly so they can be reported and added to
/// the taxonomy.
///
/// Six existing ARB keys are reused with their original names
/// (structTypeSubluxation, structTypeDislocation, structTypeInstability,
/// structTypeJointPain, structTypeMyofascial, structTypeNeuropathic).
/// The remaining 21 are new in F6.a.
extension StructuralEventTypeLocalization on String {
  String structuralTypeLabel(AppLocalizations l10n) => switch (this) {
        // joint
        'subluxation' => l10n.structTypeSubluxation,
        'dislocation' => l10n.structTypeDislocation,
        'joint_instability' => l10n.structTypeInstability,
        'joint_pain' => l10n.structTypeJointPain,
        // muscle
        'muscle_strain' => l10n.structTypeMuscleStrain,
        'muscle_distension' => l10n.structTypeMuscleDistension,
        'muscle_tear' => l10n.structTypeMuscleTear,
        'contracture' => l10n.structTypeContracture,
        'muscle_spasm' => l10n.structTypeMuscleSpasm,
        'myofascial_pain' => l10n.structTypeMyofascial,
        // tendon
        'tendinitis' => l10n.structTypeTendinitis,
        'tendinosis' => l10n.structTypeTendinosis,
        'bursitis' => l10n.structTypeBursitis,
        'enthesitis' => l10n.structTypeEnthesitis,
        'tendon_fissure' => l10n.structTypeTendonFissure,
        // ligament
        'mild_sprain' => l10n.structTypeMildSprain,
        'severe_sprain' => l10n.structTypeSevereSprain,
        'ligament_tear' => l10n.structTypeLigamentTear,
        // softTissue
        'superficial_cut' => l10n.structTypeSuperficialCut,
        'skin_fissure' => l10n.structTypeSkinFissure,
        'deep_wound' => l10n.structTypeDeepWound,
        'hematoma' => l10n.structTypeHematoma,
        'contusion' => l10n.structTypeContusion,
        'burn' => l10n.structTypeBurn,
        'abrasion' => l10n.structTypeAbrasion,
        // nerve
        'neuropathic_pain' => l10n.structTypeNeuropathic,
        'paresthesia' => l10n.structTypeParesthesia,
        // Unknown ID — log in debug builds, return raw for the UI.
        _ => _unknownIdFallback(this, 'structuralType'),
      };
}

// -----------------------------------------------------------------------------
// 3. Body zone labels (extension on String, F6.b expands the list)
// -----------------------------------------------------------------------------

/// Resolve a stable body zone ID (e.g. 'cervical', 'lumbar_pelvis') to its
/// localized display label. Existing ARB key names are kept verbatim
/// (zoneCervical, zoneHombros, etc.) — Spanish/English naming inconsistency
/// is pre-existing and not worth a sweeping rename pass right now.
extension BodyZoneLocalization on String {
  String bodyZoneLabel(AppLocalizations l10n) => switch (this) {
        // head/neck
        'cervical' => l10n.zoneCervical,
        'jaw' => l10n.zoneJaw,
        'temple' => l10n.zoneTemple,
        // shoulders/upper back
        'shoulders' => l10n.zoneHombros,
        'shoulder_blades' => l10n.zoneShoulderBlades,
        'upper_back' => l10n.zoneUpperBack,
        // arms
        'upper_arm' => l10n.zoneUpperArm,
        'elbow' => l10n.zoneElbow,
        'forearm' => l10n.zoneForearm,
        'wrists' => l10n.zoneMunecas,
        'hands' => l10n.zoneManos,
        // chest/abdomen
        'chest' => l10n.zoneChest,
        'side' => l10n.zoneSide,
        'ribs' => l10n.zoneRibs,
        'abdomen' => l10n.zoneAbdomen,
        // lower back/pelvis
        'lumbar_pelvis' => l10n.zoneLumbarPelvis,
        'hips' => l10n.zoneCaderas,
        'glutes' => l10n.zoneGlutes,
        // legs
        'front_thigh' => l10n.zoneFrontThigh,
        'back_thigh' => l10n.zoneBackThigh,
        'knees' => l10n.zoneRodillas,
        'calf' => l10n.zoneCalf,
        'ankles' => l10n.zoneTobillos,
        'feet' => l10n.zoneFeet,
        _ => _unknownIdFallback(this, 'bodyZone'),
      };
}

// -----------------------------------------------------------------------------
// 4. BodyRegion labels (F6.b)
// -----------------------------------------------------------------------------

extension BodyRegionLocalization on BodyRegion {
  String label(AppLocalizations l10n) => switch (this) {
        BodyRegion.headNeck => l10n.bodyRegionHeadNeck,
        BodyRegion.shouldersUpperBack => l10n.bodyRegionShouldersUpperBack,
        BodyRegion.arms => l10n.bodyRegionArms,
        BodyRegion.chestAbdomen => l10n.bodyRegionChestAbdomen,
        BodyRegion.lowerBackPelvis => l10n.bodyRegionLowerBackPelvis,
        BodyRegion.legs => l10n.bodyRegionLegs,
      };
}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

/// Visible fallback for unknown IDs: returns the raw string and logs a
/// debug warning. Visible-but-degraded is better than hidden — catches
/// taxonomy drift early in beta testing.
String _unknownIdFallback(String id, String category) {
  assert(() {
    debugPrint('[structural_taxonomy] Unknown $category ID: "$id" — '
        'add to lib/services/structural_taxonomy.dart and ARB.');
    return true;
  }());
  return id;
}