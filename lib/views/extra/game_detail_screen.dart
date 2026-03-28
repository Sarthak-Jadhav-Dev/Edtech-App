import 'package:flutter/material.dart';

class GameDetailScreen extends StatelessWidget {
  final String title;
  const GameDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gamepad, size: 100),
            const SizedBox(height: 20),
            const Text("Ready to play?", style: TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("START GAME"),
            ),
          ],
        ),
      ),
    );
  }
}
