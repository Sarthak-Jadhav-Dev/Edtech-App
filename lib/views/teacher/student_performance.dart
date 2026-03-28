import 'package:flutter/material.dart';

class StudentPerformanceScreen extends StatelessWidget {
  final String studentName;
  const StudentPerformanceScreen({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$studentName's Progress"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.person, size: 100),
          const SizedBox(height: 10),
          Text(
            studentName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Divider(),
          const Text("Average Quiz Score: 85%"),
          const Text("Assignments Done: 4/5"),
          const Text("Attendance: 95%"),
          const SizedBox(height: 20),
          const Text("Overall Grade: A", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
