import 'package:flutter/material.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fun with Phonics",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Learn how to read and speak English easily."),
            const SizedBox(height: 20),
            const Text(
              "What you will learn:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text("- ABC sounds"),
            const Text("- Vowels and Consonants"),
            const Text("- Reading simple words"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Action to enroll
              },
              child: const Text("Enroll Now"),
            ),
          ],
        ),
      ),
    );
  }
}
