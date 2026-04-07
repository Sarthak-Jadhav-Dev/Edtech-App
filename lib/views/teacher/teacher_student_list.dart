import 'package:flutter/material.dart';
import 'package:kte/services/firestore_service.dart';
import 'teacher_student_detail.dart';

class TeacherStudentList extends StatelessWidget {
  final String classId;

  const TeacherStudentList({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("Enrolled Students", style: TextStyle(fontFamily: "Poppins", color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: FirestoreService().getClassStudentProgress(classId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No students enrolled yet.", style: TextStyle(fontFamily: "Sans", fontSize: 16)));
          }

          final students = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    radius: 25,
                    child: Icon(Icons.person, color: Colors.purple.shade900),
                  ),
                  title: Text("${student['firstName']} ${student['lastName']}", style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text("${student['email']}", style: const TextStyle(fontFamily: "Sans", fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.purple),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => TeacherStudentDetail(classId: classId, studentData: student)
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
