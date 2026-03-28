import 'package:flutter/material.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Certificates"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.workspace_premium, size: 100, color: Colors.amber),
          const SizedBox(height: 20),
          const ListTile(
            title: Text("Course: Fun with Phonics"),
            subtitle: Text("ID: KTE-12345"),
            trailing: Icon(Icons.download),
          ),
          const ListTile(
            title: Text("Course: Math Basics"),
            subtitle: Text("ID: KTE-67890"),
            trailing: Icon(Icons.download),
          ),
        ],
      ),
    );
  }
}
