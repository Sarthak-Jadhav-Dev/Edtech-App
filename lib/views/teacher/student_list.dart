import 'package:flutter/material.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Students"),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Sarthak"),
            subtitle: Text("Progress: 85%"),
            trailing: Icon(Icons.arrow_forward),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Aarav"),
            subtitle: Text("Progress: 70%"),
            trailing: Icon(Icons.arrow_forward),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Vihaan"),
            subtitle: Text("Progress: 45%"),
            trailing: Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
