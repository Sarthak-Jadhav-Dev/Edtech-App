import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Question $currentQuestion: What is A?"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentQuestion++;
                });
              },
              child: const Text("Option 1"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Option 2"),
            ),
            const Spacer(),
            Text("Score: 0"),
          ],
        ),
      ),
    );
  }
}
