import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:kte/views/teacher/create_course.dart';
import 'package:kte/views/teacher/class_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
          );
        },
        backgroundColor: Colors.purple.shade900,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create Class", style: TextStyle(color: Colors.white, fontFamily: "Sans")),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getTeacherClasses(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No classes created yet.\nTap + to create one!", 
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "Sans", fontSize: 16)),
            );
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
                color: Colors.purple.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(classData['name'] ?? 'Unnamed', 
                    style: const TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text("Subject: ${classData['subject'] ?? 'N/A'}", style: const TextStyle(fontFamily: "Sans")),
                      Text("Students: ${(classData['enrolledStudents'] as List?)?.length ?? 0}", style: const TextStyle(fontFamily: "Sans")),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.purple),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ClassDetailScreen(classId: classId, classData: classData)
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
