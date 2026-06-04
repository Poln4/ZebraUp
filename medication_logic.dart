void checkMedicationSchedule() {
  // Set your start date (The day you began the cycle)
  DateTime startDate = DateTime(2024, 5, 20); 
  DateTime today = DateTime.now();
  
  // Calculate the difference in days
  int daysActive = today.difference(startDate).inDays;

  // NAC Logic: 3-day rotation (e.g., Take on Day 1, Rest Day 2 & 3)
  bool isNacDay = (daysActive % 3 == 0);

  print("Days since starting cycle: $daysActive");
  
  if (isNacDay) {
    print("ALERT: Today is a NAC Day. Remember to take it with water!");
  } else {
    print("MESSAGE: No NAC today. Enjoy your supplement break!");
  }

  // Bonus logic: Iron vs Calcium spacing
  print("REMINDER: Take Iron 8 hours apart from Calcium for max absorption.");
}

void main() {
  checkMedicationSchedule();
}