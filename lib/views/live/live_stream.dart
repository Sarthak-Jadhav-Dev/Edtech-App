import 'package:flutter/material.dart';

class LiveStreamScreen extends StatelessWidget {
  final String title;
  const LiveStreamScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          // Simulated Video Player
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.black,
            child: const Center(
              child: Text("Live Video Stream", style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
          const SizedBox(height: 10),
          const Text("Live Chat:", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Text("Student: Hi Teacher!"),
                Text("Teacher: Hello everyone."),
                Text("Student: This is fun!"),
              ],
            ),
          ),
          // Simple chat input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: "Type here..."),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
