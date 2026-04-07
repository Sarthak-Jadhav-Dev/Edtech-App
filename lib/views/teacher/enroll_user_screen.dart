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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${data['firstName']} enrolled successfully!")));
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
      appBar: AppBar(
        title: const Text("Enroll Student", style: TextStyle(fontFamily: "Poppins", color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Student Email",
                      prefixIcon: Icon(Icons.email, color: Colors.purple.shade400),
                      filled: true,
                      fillColor: Colors.purple.shade50.withOpacity(0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                      onPressed: _isLoading ? null : _search,
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text("Find Student", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.purple.shade900,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_message.isNotEmpty) Center(child: Text(_message, style: const TextStyle(color: Colors.red, fontFamily: "Sans", fontSize: 16))),
            if (_foundUser != null) ...[
              const Text("Search Result", style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    radius: 25,
                    child: Icon(Icons.person, color: Colors.purple.shade900, size: 30),
                  ),
                  title: Text("${_foundUser!['firstName']} ${_foundUser!['lastName']}", style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text("Role: ${_foundUser!['userType']}", style: const TextStyle(fontFamily: "Sans")),
                  trailing: ElevatedButton(
                    onPressed: _isLoading ? null : _enroll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text("Enroll", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
