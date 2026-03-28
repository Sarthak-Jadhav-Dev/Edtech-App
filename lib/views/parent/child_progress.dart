import 'package:flutter/material.dart';

class ChildProgressScreen extends StatelessWidget {
  const ChildProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Child Progress"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text("English: 75% Completed"),
          SizedBox(height: 10),
          LinearProgressIndicator(value: 0.75),
          SizedBox(height: 20),
          Text("Math: 40% Completed"),
          SizedBox(height: 10),
          LinearProgressIndicator(value: 0.40),
          SizedBox(height: 20),
          Text("Science: 10% Completed"),
          SizedBox(height: 10),
          LinearProgressIndicator(value: 0.10),
        ],
      ),
    );
  }
}
