import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Progress"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text("Course Completion:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("English: 75%"),
          Text("Math: 40%"),
          SizedBox(height: 20),
          Text("Quiz Scores:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Last Quiz: 85%"),
          Text("Average: 80%"),
          SizedBox(height: 20),
          Text("Time Spent Today:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("45 minutes"),
        ],
      ),
    );
  }
}
