import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Achievements"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.amber,
              child: Icon(Icons.stars, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text("Level 5", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("350 Points"),
            const SizedBox(height: 20),
            const Text("Badges:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.speed, color: Colors.purple),
              title: const Text("Fast Learner"),
              subtitle: const Text("Unlocked on Oct 12"),
            ),
            ListTile(
              leading: const Icon(Icons.quiz, color: Colors.purple),
              title: const Text("Quiz Master"),
              subtitle: const Text("Unlocked on Oct 10"),
            ),
          ],
        ),
      ),
    );
  }
}
