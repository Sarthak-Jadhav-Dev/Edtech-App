import 'package:flutter/material.dart';

class AssignmentListScreen extends StatelessWidget {
  const AssignmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("My Assignments"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("Due soon:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text("Phonics Worksheet 1"),
            subtitle: const Text("Due: Oct 25"),
            trailing: const Text("Pending"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text("Math Exercise"),
            subtitle: const Text("Due: Oct 22"),
            trailing: const Text("Completed"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
