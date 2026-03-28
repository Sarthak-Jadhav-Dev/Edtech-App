import 'package:flutter/material.dart';

class LessonScreen extends StatelessWidget {
  final String lessonTitle;
  const LessonScreen({super.key, required this.lessonTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lessonTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Placeholder
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black12,
              child: const Center(child: Icon(Icons.play_circle, size: 50)),
            ),
            const SizedBox(height: 20),
            const Text(
              "About this Lesson:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "This lesson explains the basics of our course. Watch the video above to learn more.",
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Mark as done
                Navigator.pop(context);
              },
              child: const Text("Finish Lesson"),
            ),
          ],
        ),
      ),
    );
  }
}
