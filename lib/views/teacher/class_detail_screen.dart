import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:kte/views/teacher/add_content_screen.dart';
import 'package:kte/views/teacher/enroll_user_screen.dart';
import 'package:kte/views/teacher/teacher_student_list.dart';
import 'package:kte/views/teacher/create_quiz_screen.dart';
import 'package:kte/views/teacher/quiz_results_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassDetailScreen extends StatelessWidget {
  final String classId;
  final Map<String, dynamic> classData;

  const ClassDetailScreen({super.key, required this.classId, required this.classData});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch \$urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: Text(classData['name'] ?? 'Class Details', style: const TextStyle(fontFamily: "Poppins")),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              bool confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Class"),
                  content: const Text("Are you sure you want to delete this class? This action cannot be undone."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                  ]
                )
              ) ?? false;
              if (confirm) {
                await FirestoreService().deleteClass(classId);
                if (context.mounted) Navigator.pop(context);
              }
            }
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Subject: ${classData['subject']}", style: const TextStyle(fontSize: 18, fontFamily: "Sans")),
            const SizedBox(height: 8),
            Text("Description: ${classData['description']}", style: const TextStyle(fontFamily: "Sans", color: Colors.black54)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherStudentList(classId: classId)));
                  },
                  icon: const Icon(Icons.people, color: Colors.white),
                  label: const Text("View Students", style: TextStyle(color: Colors.white,fontFamily:"Poppins")),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade900),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => EnrollUserScreen(classId: classId)));
                  },
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text("Enroll User", style: TextStyle(color: Colors.white,fontFamily: "Poppins")),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddContentScreen(classId: classId)));
                  },
                  icon: const Icon(Icons.library_add, color: Colors.white),
                  label: const Text("Add Content", style: TextStyle(color: Colors.white,fontFamily:"Poppins")),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CreateQuizScreen(classId: classId)));
                  },
                  icon: const Icon(Icons.quiz, color: Colors.white),
                  label: const Text("Create Quiz", style: TextStyle(color: Colors.white,fontFamily:"Poppins")),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Quizzes Section
            const Text("Quizzes", style: TextStyle(fontSize: 20, fontFamily: "Poppins", fontWeight: FontWeight.bold)),
            const Divider(),
            SizedBox(
              height: 100,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getClassQuizzes(classId),
                builder: (context, quizSnap) {
                  if (quizSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final quizzes = quizSnap.data?.docs ?? [];
                  if (quizzes.isEmpty) {
                    return const Center(child: Text("No quizzes yet. Create one!", style: TextStyle(fontFamily: "Sans")));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final qData = quizzes[index].data() as Map<String, dynamic>;
                      final qId = quizzes[index].id;
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 10),
                        child: Card(
                          elevation: 3,
                          color: Colors.deepOrange.shade50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => QuizResultsScreen(classId: classId, quizId: qId, quizTitle: qData['title'] ?? 'Quiz')
                              ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.quiz, color: Colors.deepOrange, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(qData['title'] ?? '', style: const TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (c) => AlertDialog(
                                              title: const Text("Delete Quiz"),
                                              content: const Text("Delete this quiz? This cannot be undone."),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
                                                TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                                              ],
                                            ),
                                          ) ?? false;
                                          if (confirm) await FirestoreService().deleteQuiz(classId, qId);
                                        },
                                      ),
                                    ],
                                  ),
                                  Text("${(qData['questions'] as List?)?.length ?? 0} questions", style: TextStyle(fontFamily: "Sans", fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            const Text("Course Content", style: TextStyle(fontSize: 20, fontFamily: "Poppins", fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getClassContent(classId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No content added yet.", style: TextStyle(fontFamily: "Sans")));
                  }

                  final contents = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      final contentData = contents[index].data() as Map<String, dynamic>;
                      final isVideo = contentData['type'] == 'video';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple.shade100,
                            child: Icon(isVideo ? Icons.play_circle_fill : Icons.assignment, color: Colors.purple.shade900),
                          ),
                          title: Text(contentData['title'] ?? 'No Title', style: const TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold)),
                          subtitle: Text(isVideo ? "Video Link" : "Google Form / Assignment", style: const TextStyle(fontFamily: "Sans", fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.open_in_browser, color: Colors.blue),
                                onPressed: () {
                                  if (contentData['url'] != null) {
                                    _launchUrl(contentData['url']);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Delete Material"),
                                      content: const Text("Are you sure you want to delete this material?"),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                                      ]
                                    )
                                  ) ?? false;
                                  if (confirm) {
                                    await FirestoreService().deleteContent(classId, contents[index].id);
                                  }
                                }
                              ),
                            ],
                          ),
                          onTap: () {
                            if (contentData['url'] != null) {
                              _launchUrl(contentData['url']);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
