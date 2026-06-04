import 'package:flutter/material.dart';

class ZebraAccordion extends StatefulWidget {
  @override
  _ZebraAccordionState createState() => _ZebraAccordionState();
}

class _ZebraAccordionState extends State<ZebraAccordion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Zebra Daily Tracker"),
        backgroundColor: Colors.teal.shade200, // Slightly optimistic/calm color
      ),
      body: ListView.builder(
        itemCount: zebraCategories.length,
        itemBuilder: (context, index) {
          final category = zebraCategories[index];
          return ExpansionTile(
            title: Text(
              category.title,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
            ),
            children: category.symptoms.map((symptom) {
              return CheckboxListTile(
                title: Text(symptom),
                value: false, // This will eventually link to your database
                onChanged: (bool? value) {
                  // Logic to log symptom without typing anything
                  print("Logged: $symptom at ${DateTime.now()}");
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}