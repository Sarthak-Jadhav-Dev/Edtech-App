import 'package:flutter/material.dart';

class LiveClassListScreen extends StatelessWidget {
  const LiveClassListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Classes"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Happening Now:", style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.live_tv, color: Colors.red),
            title: const Text("English: Fun with Vowels"),
            subtitle: const Text("By Mrs. Smith"),
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text("Join"),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Upcoming:", style: TextStyle(fontWeight: FontWeight.bold)),
          const ListTile(
            leading: Icon(Icons.videocam),
            title: Text("Math: Counting 1-10"),
            subtitle: Text("Today at 4:00 PM"),
          ),
        ],
      ),
    );
  }
}
