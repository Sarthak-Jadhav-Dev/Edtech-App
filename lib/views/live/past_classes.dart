import 'package:flutter/material.dart';

class PastClassesScreen extends StatelessWidget {
  const PastClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Past Classes"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.play_circle_fill),
            title: Text("Alphabet Basics"),
            subtitle: Text("Oct 10, 2023"),
          ),
          ListTile(
            leading: Icon(Icons.play_circle_fill),
            title: Text("Math: Numbers 1-5"),
            subtitle: Text("Oct 8, 2023"),
          ),
        ],
      ),
    );
  }
}
