import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Top Learners",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: CircleAvatar(child: Text("1")),
                  title: Text("Sarthak"),
                  trailing: Text("2500 pts"),
                ),
                ListTile(
                  leading: CircleAvatar(child: Text("2")),
                  title: Text("Aarav"),
                  trailing: Text("2350 pts"),
                ),
                ListTile(
                  leading: CircleAvatar(child: Text("3")),
                  title: Text("Vihaan"),
                  trailing: Text("2200 pts"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
