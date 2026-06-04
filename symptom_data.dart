class SymptomCategory {
  final String title;
  final List<String> symptoms;
  bool isExpanded;

  SymptomCategory({
    required this.title,
    required this.symptoms,
    this.isExpanded = false,
  });
}

// This list pulls directly from your uploaded EDS/HSD diagnostic criteria
List<SymptomCategory> zebraCategories = [
  SymptomCategory(
    title: "Joints & Mobility",
    symptoms: ["Subluxation", "Clicking", "Chronic Pain", "Instability"],
  ),
  SymptomCategory(
    title: "Skin & Tissue",
    symptoms: ["Easy Bruising", "Stretchy Skin", "Fragility", "Slow Healing"],
  ),
  SymptomCategory(
    title: "Systemic (Dysautonomia/MCAS)",
    symptoms: ["Dizziness (POTS)", "Tachycardia", "Brain Fog", "Heat Intolerance"],
  ),
];