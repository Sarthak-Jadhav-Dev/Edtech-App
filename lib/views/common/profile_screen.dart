import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Icon(Icons.person, size: 100),
            const Text("Name: Sarthak", style: TextStyle(fontSize: 20)),
            const Text("Email: sarthak@mail.com"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Edit Profile"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
