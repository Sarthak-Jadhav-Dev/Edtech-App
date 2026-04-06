import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kte/services/firestore_service.dart';

class EnrollUserScreen extends StatefulWidget {
  final String classId;

  const EnrollUserScreen({super.key, required this.classId});

  @override
  State<EnrollUserScreen> createState() => _EnrollUserScreenState();
}

class _EnrollUserScreenState extends State<EnrollUserScreen> {
  final _emailController = TextEditingController();
  DocumentSnapshot? _foundUser;
  bool _isLoading = false;
  String _message = "";

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _message = "";
      _foundUser = null;
    });

    final doc = await FirestoreService().searchUserByEmail(_emailController.text.trim());
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['userType'] == 'Teacher') {
        _message = "Cannot enroll a Teacher.";
      } else {
        _foundUser = doc;
      }
    } else {
      _message = "User not found.";
    }

    setState(() => _isLoading = false);
  }

  Future<void> _enroll() async {
    if (_foundUser == null) return;
    
    setState(() => _isLoading = true);
    final data = _foundUser!.data() as Map<String, dynamic>;
    
    bool success = await FirestoreService().enrollUser(widget.classId, _foundUser!.id, data['userType']);
    
    setState(() => _isLoading = false);
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("\${data['firstName']} enrolled successfully!")));
        Navigator.pop(context);
      }
    } else {
      setState(() => _message = "Failed to enroll user.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(title: const Text("Enroll User", style: TextStyle(fontFamily: "Poppins")), backgroundColor: Colors.transparent),
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
                      hintText: "Enter user email",
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
            if (_foundUser != null) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text("\${_foundUser!['firstName']} \${_foundUser!['lastName']}", style: const TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold)),
                  subtitle: Text("Role: \${_foundUser!['userType']}", style: const TextStyle(fontFamily: "Sans")),
                  trailing: ElevatedButton(
                    onPressed: _enroll,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700),
                    child: const Text("Enroll", style: TextStyle(color: Colors.white)),
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
