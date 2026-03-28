import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              "Congratulations!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text("You scored 8/10"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Go back to the module or home
                Navigator.pop(context);
              },
              child: const Text("Back to Course"),
            ),
          ],
        ),
      ),
    );
  }
}
