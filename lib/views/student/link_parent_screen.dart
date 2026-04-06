import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kte/services/firestore_service.dart';

class LinkParentScreen extends StatefulWidget {
  const LinkParentScreen({super.key});

  @override
  State<LinkParentScreen> createState() => _LinkParentScreenState();
}

class _LinkParentScreenState extends State<LinkParentScreen> {
  final _emailController = TextEditingController();
  DocumentSnapshot? _foundParent;
  bool _isLoading = false;
  String _message = "";

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _message = "";
      _foundParent = null;
    });

    final doc = await FirestoreService().searchUserByEmail(_emailController.text.trim());
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['userType'] == 'Parent') {
        _foundParent = doc;
      } else {
        _message = "Found user is not a Parent.";
      }
    } else {
      _message = "Parent not found.";
    }

    setState(() => _isLoading = false);
  }

  Future<void> _link() async {
    if (_foundParent == null) return;
    
    setState(() => _isLoading = true);
    
    final studentId = FirebaseAuth.instance.currentUser?.uid;
    if (studentId != null) {
      bool success = await FirestoreService().linkParentToStudent(studentId, _foundParent!.id);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Linked to Parent successfully!")));
          Navigator.pop(context);
        }
      } else {
        setState(() => _message = "Failed to link parent.");
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(title: const Text("Link Parent", style: TextStyle(fontFamily: "Poppins")), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Enter Parent's Email",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.purple.shade900,
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _search,
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_message.isNotEmpty) Text(_message, style: const TextStyle(color: Colors.red, fontFamily: "Sans")),
            if (_foundParent != null) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text("\${_foundParent!['firstName']} \${_foundParent!['lastName']}", style: const TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold)),
                  subtitle: const Text("Role: Parent", style: TextStyle(fontFamily: "Sans")),
                  trailing: ElevatedButton(
                    onPressed: _link,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700),
                    child: const Text("Link", style: TextStyle(color: Colors.white)),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
