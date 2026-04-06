import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:kte/views/student/class_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("My Courses", style: TextStyle(fontFamily: "Poppins")),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getEnrolledClasses(uid, 'Student'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("You are not enrolled in any courses yet.", style: TextStyle(fontFamily: "Sans")));
          }

          final classes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index].data() as Map<String, dynamic>;
              final classId = classes[index].id;

              return Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purpleAccent,
                    child: Icon(Icons.book, color: Colors.white),
                  ),
                  title: Text(classData['name'] ?? 'Unnamed', style: const TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text("Subject: \${classData['subject']}", style: const TextStyle(fontFamily: "Sans")),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.purple),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => StudentClassDetailScreen(classId: classId, classData: classData)
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
