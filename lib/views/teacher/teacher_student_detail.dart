import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:kte/views/common/personalized_ai_report_screen.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Student Progress", style: TextStyle(fontFamily: "Poppins", color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
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
                  Text("${studentData['firstName']} ${studentData['lastName']}", style: TextStyle(fontFamily: "Poppins", fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  Text(studentData['email'] ?? "", style: TextStyle(fontFamily: "Sans", fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withAlpha(153))),
                  const SizedBox(height: 20),
                  
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PersonalizedAiReportScreen(
                          studentId: studentData['uid'] ?? '',
                          studentName: "${studentData['firstName']} ${studentData['lastName']}",
                          classId: classId,
                        ),
                      ));
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text("Generate AI Holistic Report", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                          Text("Course Completion", style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.purple.shade100,
                            color: Colors.green,
                            minHeight: 15,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 10),
                          Text("${percentage.toStringAsFixed(1)}% Completed", style: TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                          Text("${completedProps.length} out of $totalContents items finished.", style: TextStyle(fontFamily: "Sans", color: Theme.of(context).colorScheme.onSurface.withAlpha(153))),
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
                          Text("Recent Activity", style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                          Divider(color: Theme.of(context).colorScheme.onSurface.withAlpha(50)),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
                            title: Text("Last Viewed Material", style: TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                            subtitle: Text(lastViewedTitle, style: TextStyle(fontFamily: "Sans", color: Theme.of(context).colorScheme.onSurface.withAlpha(153))),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.family_restroom, color: Theme.of(context).colorScheme.primary),
                            title: Text("Linked Parents", style: TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                            subtitle: Text(
                              (studentData['linkedParentIds'] as List?)?.isEmpty ?? true 
                                ? "None Linked" 
                                : "${(studentData['linkedParentIds'] as List).length} connected", 
                              style: TextStyle(fontFamily: "Sans", color: Theme.of(context).colorScheme.onSurface.withAlpha(153))
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
