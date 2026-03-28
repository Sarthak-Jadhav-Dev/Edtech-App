import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text("Dark Mode"),
            trailing: Icon(Icons.toggle_off),
          ),
          const ListTile(
            title: Text("Language"),
            trailing: Text("English"),
          ),
          ListTile(
            title: const Text("Change Password"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Terms & Conditions"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
