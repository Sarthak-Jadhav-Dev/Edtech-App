import 'package:flutter/material.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Courses"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text("English for Kids"),
            subtitle: const Text("Level: Beginner"),
            onTap: () {
              // Action when clicked
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text("Math Adventures"),
            subtitle: const Text("Level: Beginner"),
            onTap: () {
              // Action when clicked
            },
          ),
        ],
      ),
    );
  }
}
