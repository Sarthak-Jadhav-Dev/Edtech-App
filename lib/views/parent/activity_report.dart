import 'package:flutter/material.dart';

class ActivityReportScreen extends StatelessWidget {
  const ActivityReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Report"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text("Weekly Summary:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Monday: 45 minutes"),
          Text("Tuesday: 30 minutes"),
          Text("Wednesday: 1 hour"),
          Text("Thursday: 20 minutes"),
          Text("Friday: 50 minutes"),
          SizedBox(height: 20),
          Text("Total Time this week: 3h 25m"),
          SizedBox(height: 20),
          Text("Recent Lessons Completed:", style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: Text("Intro to Vowels"),
            subtitle: Text("Completed 2 hours ago"),
          ),
          ListTile(
            title: Text("Counting 1-10"),
            subtitle: Text("Completed yesterday"),
          ),
        ],
      ),
    );
  }
}
