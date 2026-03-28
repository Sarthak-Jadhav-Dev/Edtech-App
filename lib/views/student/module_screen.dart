import 'package:flutter/material.dart';
import 'package:kte/views/student/lesson_screen.dart';

class ModuleScreen extends StatelessWidget {
  final String moduleTitle;
  const ModuleScreen({super.key, required this.moduleTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(moduleTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Progress: 25%"),
          const SizedBox(height: 20),
          const Text("Lessons in this module:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.play_circle),
            title: const Text("Lesson 1: Introduction"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LessonScreen(lessonTitle: "Lesson 1")),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.play_circle),
            title: const Text("Lesson 2: Basics"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LessonScreen(lessonTitle: "Lesson 2")),
              );
            },
          ),
        ],
      ),
    );
  }
}
