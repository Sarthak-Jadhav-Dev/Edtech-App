import 'package:flutter/material.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _subjectController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _createClass() async {
    if (_nameController.text.trim().isEmpty || _subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Subject are required.')));
      return;
    }
    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final id = await FirestoreService().createClass(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        subject: _subjectController.text.trim(),
        teacherId: uid,
      );

      if (id != null && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class created successfully!')));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create class.')));
      }
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("Create Class", style: TextStyle(fontFamily: "Poppins", color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 200,
                child: Center(
                  child: Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_z01bika0.json',
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.school, size: 120, color: Colors.purple.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Class Name",
                        prefixIcon: Icon(Icons.class_, color: Colors.purple.shade400),
                        filled: true,
                        fillColor: Colors.purple.shade50.withValues(alpha: 0.5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        labelText: "Subject",
                        prefixIcon: Icon(Icons.book, color: Colors.purple.shade400),
                        filled: true,
                        fillColor: Colors.purple.shade50.withValues(alpha: 0.5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Description (Optional)",
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: Icon(Icons.description, color: Colors.purple.shade400),
                        ),
                        filled: true,
                        fillColor: Colors.purple.shade50.withValues(alpha: 0.5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _isLoading ? const CircularProgressIndicator() : ElevatedButton(
                            onPressed: _createClass,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 55),
                              backgroundColor: Colors.purple.shade900,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 5,
                            ),
                            child: const Text("Create Class", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 18)),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
