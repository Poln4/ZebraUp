// C.2 — Compendium domain mapping
//
// Groups the 73 JSON `condition` values into 14 clinical domains for the
// compendium expanders, with localized labels in es / en / zh-TW.
//
// The condition values in zebra_wisdom.json are English strings curated
// manually. When new conditions are added to the JSON, missing entries
// here fall back to CompendiumDomain.other (rendered under the localized
// "Otros" / "Other" / "其他" header), so nothing breaks if the data adds
// new categories.
//
// User-condition matching is keyword-based: a user with "POTS, hEDS,
// MCAS" in their profile matches dysautonomiaPots + connectiveTissue +
// fascia + exerciseRehab + mcasInflammation. Matched domains are shown
// first in the compendium and auto-expanded.

import '../l10n/app_localizations.dart';

enum CompendiumDomain {
  dysautonomiaPots,
  connectiveTissueJointsEyes,
  fascia,
  exerciseRehab,
  mcasInflammation,
  ironHematology,
  bleedingVascular,
  neurodivergenceSensory,
  gastrointestinal,
  hormonesPelvicFloor,
  proceduresEmergencies,
  mentalHealthStress,
  feet,
  other,
}

/// JSON `condition` strings → CompendiumDomain. Exhaustive mapping of
/// the 73 current categories. Anything not in this map falls to .other.
const Map<String, CompendiumDomain> kConditionToDomain = {
  // Dysautonomia & POTS
  'Autonomic Overload': CompendiumDomain.dysautonomiaPots,
  'Dysautonomia & Hydration': CompendiumDomain.dysautonomiaPots,
  'Dysautonomia Manifestations': CompendiumDomain.dysautonomiaPots,
  'POTS & ADHD': CompendiumDomain.dysautonomiaPots,
  'POTS & Cerebral Perfusion': CompendiumDomain.dysautonomiaPots,
  'POTS & Exercise': CompendiumDomain.dysautonomiaPots,
  'POTS & Quality of Life': CompendiumDomain.dysautonomiaPots,
  'POTS & Sodium Intake': CompendiumDomain.dysautonomiaPots,
  'Pelvic Floor & Dysautonomia': CompendiumDomain.dysautonomiaPots,
  'Vagal Tone Improvement': CompendiumDomain.dysautonomiaPots,

  // Connective tissue, joints, eyes
  'Biomechanics': CompendiumDomain.connectiveTissueJointsEyes,
  'Cervical Instability': CompendiumDomain.connectiveTissueJointsEyes,
  'Shoulder Instability': CompendiumDomain.connectiveTissueJointsEyes,
  'EDS & Proprioceptive Learning': CompendiumDomain.connectiveTissueJointsEyes,
  'Proprioception': CompendiumDomain.connectiveTissueJointsEyes,
  'TMJ & Cervical Synergy': CompendiumDomain.connectiveTissueJointsEyes,
  'Tendon Elongation & Strength Training':
      CompendiumDomain.connectiveTissueJointsEyes,
  'Endothelial Fragility': CompendiumDomain.connectiveTissueJointsEyes,
  'Integrin Signaling': CompendiumDomain.connectiveTissueJointsEyes,
  'Ocular Manifestations': CompendiumDomain.connectiveTissueJointsEyes,

  // Fascia
  'Fascia & Adipose Disorders': CompendiumDomain.fascia,
  'Fascia & Proprioception': CompendiumDomain.fascia,
  'Fascia Densification': CompendiumDomain.fascia,
  'Fascial Gliding': CompendiumDomain.fascia,
  'Fascial Therapies': CompendiumDomain.fascia,

  // Exercise & rehab
  'EDS & Eccentric Exercise': CompendiumDomain.exerciseRehab,
  'EDS & Exercise (Calisthenics Tempo)': CompendiumDomain.exerciseRehab,
  'EDS & Exercise Recovery (DOMS)': CompendiumDomain.exerciseRehab,
  'Exercise Adaptation': CompendiumDomain.exerciseRehab,
  'Gradual Loading': CompendiumDomain.exerciseRehab,
  'Physical Therapy Modifications': CompendiumDomain.exerciseRehab,
  'Physical Therapy Standards': CompendiumDomain.exerciseRehab,
  'Therapist Selection': CompendiumDomain.exerciseRehab,
  'Myofascial Trigger Points': CompendiumDomain.exerciseRehab,

  // MCAS & inflammation
  'EDS & Mast Cell Activation (MCAS)': CompendiumDomain.mcasInflammation,
  'MCAS & Neuro-inflammation': CompendiumDomain.mcasInflammation,
  'Inflammation & Fatigue': CompendiumDomain.mcasInflammation,
  'Chronic Fatigue & Inflammation (TGF-β1)': CompendiumDomain.mcasInflammation,

  // Iron & hematology
  'Adenomyosis & Iron': CompendiumDomain.ironHematology,
  'Functional Iron Deficiency': CompendiumDomain.ironHematology,
  'Iron Reference Ranges': CompendiumDomain.ironHematology,
  'Myofascial Pain Syndrome & Iron Deficiency': CompendiumDomain.ironHematology,
  'Treating Iron Deficiency': CompendiumDomain.ironHematology,
  'Hematology Advocacy': CompendiumDomain.ironHematology,
  'Blood Panel Advocacy': CompendiumDomain.ironHematology,

  // Bleeding & vascular fragility
  'Bleeding Diathesis': CompendiumDomain.bleedingVascular,
  'Platelet Defects': CompendiumDomain.bleedingVascular,
  'Thrombocytopathy': CompendiumDomain.bleedingVascular,
  'vEDS Emergency Preparedness': CompendiumDomain.bleedingVascular,

  // Neurodivergence & sensory
  'ADHD & Connective Tissue': CompendiumDomain.neurodivergenceSensory,
  'EDS & Neurodivergence (ASD/ADHD)': CompendiumDomain.neurodivergenceSensory,
  'EDS & Sensory Processing': CompendiumDomain.neurodivergenceSensory,
  'Neurodivergence & Pain': CompendiumDomain.neurodivergenceSensory,
  'Neurodivergence & Pain Sensitivity': CompendiumDomain.neurodivergenceSensory,
  'Neurodivergence & Proprioception': CompendiumDomain.neurodivergenceSensory,
  'Visual Processing & ASD': CompendiumDomain.neurodivergenceSensory,

  // Gastrointestinal
  'Gastrointestinal Issues & The Nervous System':
      CompendiumDomain.gastrointestinal,
  'The Gut-Brain-Joint Axis': CompendiumDomain.gastrointestinal,

  // Hormones & pelvic floor
  'Hormones & Laxity': CompendiumDomain.hormonesPelvicFloor,
  'Relaxin & EDS': CompendiumDomain.hormonesPelvicFloor,
  'Pelvic Floor & EDS': CompendiumDomain.hormonesPelvicFloor,

  // Medical procedures & emergencies
  'Medical Procedures & Anesthesia': CompendiumDomain.proceduresEmergencies,
  'Iatrogenic Injuries': CompendiumDomain.proceduresEmergencies,
  'Surgical Preparedness': CompendiumDomain.proceduresEmergencies,
  'Emergency Preparedness': CompendiumDomain.proceduresEmergencies,
  'Emergency Transport': CompendiumDomain.proceduresEmergencies,
  'Multidisciplinary Care': CompendiumDomain.proceduresEmergencies,
  'Root Cause Management': CompendiumDomain.proceduresEmergencies,

  // Mental health, stress, nervous system
  'Chronic Stress & EDS': CompendiumDomain.mentalHealthStress,
  'Mental Health & Foot Pain': CompendiumDomain.mentalHealthStress,
  "The 'Zebra' Nervous System": CompendiumDomain.mentalHealthStress,

  // Feet
  'Foot Functionality': CompendiumDomain.feet,
  'Foot Orthotics & Fatigue': CompendiumDomain.feet,
};

/// Per-domain localized labels. Three locales: 'es', 'en', 'zh'.
/// Falls back to 'en' then '???' if locale not present.
const Map<CompendiumDomain, Map<String, String>> _domainLabels = {
  CompendiumDomain.dysautonomiaPots: {
    'es': 'Disautonomía y POTS',
    'en': 'Dysautonomia and POTS',
    'zh': '自主神經失調與 POTS',
  },
  CompendiumDomain.connectiveTissueJointsEyes: {
    'es': 'Tejido conectivo, articulaciones y ojos',
    'en': 'Connective tissue, joints and eyes',
    'zh': '結締組織、關節與眼睛',
  },
  CompendiumDomain.fascia: {'es': 'Fascia', 'en': 'Fascia', 'zh': '筋膜'},
  CompendiumDomain.exerciseRehab: {
    'es': 'Ejercicio y rehabilitación',
    'en': 'Exercise and rehabilitation',
    'zh': '運動與復健',
  },
  CompendiumDomain.mcasInflammation: {
    'es': 'MCAS e inflamación',
    'en': 'MCAS and inflammation',
    'zh': 'MCAS 與發炎',
  },
  CompendiumDomain.ironHematology: {
    'es': 'Hierro y hematología',
    'en': 'Iron and hematology',
    'zh': '鐵與血液學',
  },
  CompendiumDomain.bleedingVascular: {
    'es': 'Hemorragia y fragilidad vascular',
    'en': 'Bleeding and vascular fragility',
    'zh': '出血與血管脆弱性',
  },
  CompendiumDomain.neurodivergenceSensory: {
    'es': 'Neurodivergencia y procesamiento sensorial',
    'en': 'Neurodivergence and sensory processing',
    'zh': '神經多樣性與感覺處理',
  },
  CompendiumDomain.gastrointestinal: {
    'es': 'Gastrointestinal y eje intestino-cerebro',
    'en': 'Gastrointestinal and gut-brain axis',
    'zh': '腸胃道與腸腦軸',
  },
  CompendiumDomain.hormonesPelvicFloor: {
    'es': 'Hormonas y suelo pélvico',
    'en': 'Hormones and pelvic floor',
    'zh': '荷爾蒙與骨盆底',
  },
  CompendiumDomain.proceduresEmergencies: {
    'es': 'Procedimientos médicos, anestesia y emergencias',
    'en': 'Medical procedures, anesthesia and emergencies',
    'zh': '醫療程序、麻醉與急診',
  },
  CompendiumDomain.mentalHealthStress: {
    'es': 'Salud mental, estrés y sistema nervioso',
    'en': 'Mental health, stress and nervous system',
    'zh': '心理健康、壓力與神經系統',
  },
  CompendiumDomain.feet: {
    'es': 'Salud podal',
    'en': 'Foot health',
    'zh': '足部健康',
  },
  CompendiumDomain.other: {'es': 'Otros', 'en': 'Other', 'zh': '其他'},
};

/// Returns the domain for a JSON `condition` value. Unknown values map
/// to CompendiumDomain.other.
CompendiumDomain domainForCondition(String condition) {
  return kConditionToDomain[condition] ?? CompendiumDomain.other;
}

/// Returns the set of domains a user-profile condition string matches.
/// Keyword-based, case-insensitive. One user condition can match multiple
/// domains (e.g. "hEDS" matches connectiveTissue + fascia + exerciseRehab).
Set<CompendiumDomain> domainsForUserCondition(String userCondition) {
  final c = userCondition.toLowerCase();
  final out = <CompendiumDomain>{};

  // POTS, dysautonomia
  if (c.contains('pots') ||
      c.contains('disautonom') ||
      c.contains('dysautonom')) {
    out.add(CompendiumDomain.dysautonomiaPots);
  }

  // EDS variants (hEDS, cEDS, clEDS, vEDS, kEDS, etc.)
  if (c.contains('eds') || c.contains('ehlers') || c.contains('danlos')) {
    out.add(CompendiumDomain.connectiveTissueJointsEyes);
    out.add(CompendiumDomain.fascia);
    out.add(CompendiumDomain.exerciseRehab);
  }

  // vEDS-specific: add bleeding/vascular
  if (c.contains('veds') ||
      c.contains('vascular eds') ||
      c.contains('vascular ehlers')) {
    out.add(CompendiumDomain.bleedingVascular);
  }

  // MCAS
  if (c.contains('mcas') || c.contains('mast cell')) {
    out.add(CompendiumDomain.mcasInflammation);
  }

  // Neurodivergence
  if (c.contains('adhd') ||
      c.contains('tdah') ||
      c.contains('asd') ||
      c.contains('autis') ||
      c.contains('tea') ||
      c.contains('neurodiverg')) {
    out.add(CompendiumDomain.neurodivergenceSensory);
  }

  // Iron / anemia
  if (c.contains('iron') ||
      c.contains('hierro') ||
      c.contains('ferritin') ||
      c.contains('anemia') ||
      c.contains('鐵')) {
    out.add(CompendiumDomain.ironHematology);
  }

  // Gastrointestinal
  if (c.contains('sii') ||
      c.contains('ibs') ||
      c.contains('intest') ||
      c.contains('gastr') ||
      c.contains('gut') ||
      c.contains('colon')) {
    out.add(CompendiumDomain.gastrointestinal);
  }

  // Pelvic floor / hormones
  if (c.contains('endomet') ||
      c.contains('pcos') ||
      c.contains('sop') ||
      c.contains('adenomi') ||
      c.contains('suelo p') ||
      c.contains('pelvic floor')) {
    out.add(CompendiumDomain.hormonesPelvicFloor);
  }

  return out;
}

/// Pick the localized label for a domain. Falls back to English then a
/// placeholder if a locale is missing. The locale code comes from
/// `AppLocalizations.localeName` (e.g. 'es', 'en', 'zh_TW').
String localizedDomainLabel(CompendiumDomain domain, AppLocalizations l10n) {
  final code = l10n.localeName.toLowerCase();
  final lang = code.startsWith('zh')
      ? 'zh'
      : code.startsWith('en')
      ? 'en'
      : 'es';
  final labels = _domainLabels[domain];
  if (labels == null) return '???';
  return labels[lang] ?? labels['en'] ?? labels['es'] ?? '???';
}
