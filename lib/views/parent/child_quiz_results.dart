import 'package:flutter/material.dart';

class ChildQuizResultsScreen extends StatelessWidget {
  const ChildQuizResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Results"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text("Phonics Quiz 1"),
            subtitle: Text("Score: 9/10"),
            trailing: Text("Oct 22"),
          ),
          ListTile(
            title: Text("Math Quiz 1"),
            subtitle: Text("Score: 7/10"),
            trailing: Text("Oct 20"),
          ),
          ListTile(
            title: Text("Science Quiz 1"),
            subtitle: Text("Score: 10/10"),
            trailing: Text("Oct 18"),
          ),
        ],
      ),
    );
  }
}
