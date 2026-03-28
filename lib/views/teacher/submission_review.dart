import 'package:flutter/material.dart';

class SubmissionReviewScreen extends StatelessWidget {
  final String studentName;
  final String assignmentTitle;
  const SubmissionReviewScreen({super.key, required this.studentName, required this.assignmentTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Work"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Student: $studentName"),
            Text("Assignment: $assignmentTitle"),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: "Score",
                hintText: "e.g. 90/100",
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: "Feedback",
                hintText: "Enter feedback here",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Submit Grade"),
            ),
          ],
        ),
      ),
    );
  }
}
