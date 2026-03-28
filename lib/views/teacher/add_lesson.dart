import 'package:flutter/material.dart';

class AddLessonScreen extends StatefulWidget {
  const AddLessonScreen({super.key});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  String lessonTitle = "";
  String lessonType = "Video";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Lesson"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                lessonTitle = value;
              },
              decoration: const InputDecoration(
                labelText: "Lesson Title",
                hintText: "Enter title here",
              ),
            ),
            const SizedBox(height: 20),
            
            // Dropdown for Type
            const Text("Select Lesson Type:"),
            DropdownButton<String>(
              value: lessonType,
              items: ["Video", "Reading", "Interactive"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  lessonType = newValue!;
                });
              },
            ),
            const SizedBox(height: 40),
            
            // Save Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Save Lesson"),
            ),
          ],
        ),
      ),
    );
  }
}
