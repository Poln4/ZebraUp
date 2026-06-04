// Core Logic to avoid overwhelming the patient
class SymptomNode {
  String name;
  bool isEnabled;
  List<String> subSymptoms;

  SymptomNode({required this.name, this.isEnabled = false, required this.subSymptoms});
}

void main() {
  // 1. Initial State: Simple and General
  Map<String, SymptomNode> symptomTree = {
    'Joints': SymptomNode(name: 'Joint Issues', subSymptoms: ['Subluxation', 'Chronic Pain', 'Clicking']),
    'Skin': SymptomNode(name: 'Skin Issues', subSymptoms: ['Fragility', 'Stretchy Skin', 'Easy Bruising']),
    'Systemic': SymptomNode(name: 'Internal/Systemic', subSymptoms: ['Dizziness', 'Tachycardia', 'Brain Fog']),
  };

  // 2. Logic: Only reveal specifics if a category is "Active"
  // This prevents the user from seeing 50 symptoms at once.
  print("--- Patient Dashboard View ---");
  symptomTree.forEach((key, value) {
    if (value.isEnabled) {
      print("Visible Module: ${value.name}");
      print("Specifics to track: ${value.subSymptoms.join(', ')}");
    } else {
      print("Module ${value.name} is hidden (Mental break mode)");
    }
  });
}