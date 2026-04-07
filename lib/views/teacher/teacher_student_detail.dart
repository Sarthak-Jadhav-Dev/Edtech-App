import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kte/services/firestore_service.dart';

class TeacherStudentDetail extends StatelessWidget {
  final String classId;
  final Map<String, dynamic> studentData;

  const TeacherStudentDetail({super.key, required this.classId, required this.studentData});

  @override
  Widget build(BuildContext context) {
    final progress = studentData['progress'] as Map<String, dynamic>? ?? {};
    final completedProps = List<String>.from(progress['completedContentIds'] ?? []);
    final lastViewedTitle = progress['lastViewedTitle'] ?? "None";
    
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("Student Progress", style: TextStyle(fontFamily: "Poppins", color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirestoreService().getClassContent(classId).first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalContents = snapshot.data?.docs.length ?? 0;
          final percentage = totalContents == 0 ? 0.0 : (completedProps.length / totalContents) * 100;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.purple.shade200,
                    child: Text(
                      studentData['firstName']?[0].toUpperCase() ?? "?",
                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text("${studentData['firstName']} ${studentData['lastName']}", style: const TextStyle(fontFamily: "Poppins", fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(studentData['email'] ?? "", style: const TextStyle(fontFamily: "Sans", fontSize: 16)),
                  const SizedBox(height: 20),
                  
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Course Completion", style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.purple.shade100,
                            color: Colors.green,
                            minHeight: 15,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 10),
                          Text("${percentage.toStringAsFixed(1)}% Completed", style: const TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold)),
                          Text("${completedProps.length} out of $totalContents items finished.", style: const TextStyle(fontFamily: "Sans", color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Recent Activity", style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.history, color: Colors.purple.shade600),
                            title: const Text("Last Viewed Material", style: TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold)),
                            subtitle: Text(lastViewedTitle, style: const TextStyle(fontFamily: "Sans")),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.family_restroom, color: Colors.purple.shade600),
                            title: const Text("Linked Parents", style: TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              (studentData['linkedParentIds'] as List?)?.isEmpty ?? true 
                                ? "None Linked" 
                                : "${(studentData['linkedParentIds'] as List).length} connected", 
                              style: const TextStyle(fontFamily: "Sans")
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
