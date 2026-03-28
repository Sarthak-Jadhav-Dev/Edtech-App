import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("New Course Available"),
            subtitle: Text("Check out 'Math Adventures' now!"),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Assignment Graded"),
            subtitle: Text("Your Phonics worksheet has been reviewed."),
          ),
        ],
      ),
    );
  }
}
