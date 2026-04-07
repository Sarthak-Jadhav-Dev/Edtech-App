import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:kte/views/common/youtube_player_screen.dart';
import 'package:kte/views/student/take_quiz_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentClassDetailScreen extends StatelessWidget {
  final String classId;
  final Map<String, dynamic> classData;

  const StudentClassDetailScreen({super.key, required this.classId, required this.classData});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch \$urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: Text(classData['name'] ?? 'Course Detail', style: const TextStyle(fontFamily: "Poppins", color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getClassContent(classId),
        builder: (context, contentSnapshot) {
          if (contentSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final contents = contentSnapshot.data?.docs ?? [];
          final totalContents = contents.length;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('progress').snapshots(),
            builder: (context, progressSnapshot) {
              final progressDocs = progressSnapshot.data?.docs ?? [];
              final progressMap = {for (var doc in progressDocs) doc.id: doc.data() as Map<String, dynamic>};
              
              // Calculate class progress
              int completedVideos = 0;
              for (var content in contents) {
                final contentData = content.data() as Map<String, dynamic>;
                final videoId = contentData['videoId'];
                if (videoId != null && progressMap[videoId]?['completed'] == true) {
                  completedVideos++;
                }
              }
              
              final percentage = totalContents == 0 ? 0.0 : (completedVideos / totalContents);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Subject: ${classData['subject']}", style: const TextStyle(fontSize: 18, fontFamily: "Sans", fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text("${classData['description']}", style: const TextStyle(fontFamily: "Sans", color: Colors.black54)),
                    const SizedBox(height: 15),

                    // Progress Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Course Progress", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
                                Text("${(percentage * 100).toStringAsFixed(0)}%", style: const TextStyle(fontFamily: "Poppins", color: Colors.purple, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: percentage,
                              minHeight: 10,
                              backgroundColor: Colors.purple.shade100,
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const SizedBox(height: 10),

                    const SizedBox(height: 15),
                    // Quizzes Section
                    const Text("Quizzes", style: TextStyle(fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.bold)),
                    const Divider(),
                    SizedBox(
                      height: 80,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirestoreService().getClassQuizzes(classId),
                        builder: (context, quizSnap) {
                          if (quizSnap.connectionState == ConnectionState.waiting) {
                            return const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                          }
                          final quizzes = quizSnap.data?.docs ?? [];
                          if (quizzes.isEmpty) {
                            return const Center(child: Text("No quizzes available.", style: TextStyle(fontFamily: "Sans", fontSize: 13)));
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: quizzes.length,
                            itemBuilder: (context, index) {
                              final qData = quizzes[index].data() as Map<String, dynamic>;
                              final qId = quizzes[index].id;
                              final questions = qData['questions'] as List<dynamic>? ?? [];
                              return Container(
                                width: 200,
                                margin: const EdgeInsets.only(right: 10),
                                child: Card(
                                  elevation: 3,
                                  color: Colors.deepOrange.shade50,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () async {
                                      // Check if already taken
                                      final existing = await FirestoreService().getStudentQuizResult(classId, qId, uid);
                                      if (existing != null && existing.docs.isNotEmpty && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You already completed this quiz!')));
                                        return;
                                      }
                                      if (context.mounted) {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (_) => TakeQuizScreen(
                                            classId: classId,
                                            quizId: qId,
                                            title: qData['title'] ?? 'Quiz',
                                            questions: questions,
                                            timeLimitMinutes: qData['timeLimitMinutes'] ?? 10,
                                          ),
                                        ));
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.quiz, color: Colors.deepOrange, size: 18),
                                              const SizedBox(width: 6),
                                              Expanded(child: Text(qData['title'] ?? 'Quiz', style: const TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text("${questions.length}Q • ${qData['timeLimitMinutes'] ?? 10} min", style: TextStyle(fontFamily: "Sans", fontSize: 11, color: Colors.grey.shade600)),
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
                      child: contents.isEmpty
                          ? const Center(child: Text("No content available yet.", style: TextStyle(fontFamily: "Sans")))
                          : ListView.builder(
                              itemCount: contents.length,
                              itemBuilder: (context, index) {
                                  final contentDoc = contents[index];
                                  final contentData = contentDoc.data() as Map<String, dynamic>;
                                  final type = contentData['type'] ?? 'video';

                                  if (type == 'video') {
                                    final videoId = contentData['videoId'];
                                    final videoProgress = videoId != null ? progressMap[videoId] : null;
                                    final watchedPercent = (videoProgress?['watchedPercentage'] as num?)?.toDouble() ?? 0.0;
                                    final isCompleted = videoProgress?['completed'] == true;

                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: isCompleted ? Colors.green.shade100 : Colors.purple.shade100,
                                              child: Icon(
                                                isCompleted ? Icons.check : Icons.play_circle_fill, 
                                                color: isCompleted ? Colors.green : Colors.purple.shade900
                                              ),
                                            ),
                                            title: Text(contentData['title'] ?? 'No Title', style: TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold, decoration: isCompleted ? TextDecoration.lineThrough : null)),
                                            subtitle: Text(watchedPercent > 0 ? "Progress: ${watchedPercent.toStringAsFixed(0)}%" : "YouTube Video", style: const TextStyle(fontFamily: "Sans", fontSize: 12)),
                                            trailing: const Icon(Icons.play_arrow),
                                            onTap: () {
                                              if (videoId != null) {
                                                Navigator.push(context, MaterialPageRoute(
                                                  builder: (_) => YouTubePlayerScreen(
                                                    videoId: videoId,
                                                    title: contentData['title'] ?? 'Video',
                                                  )
                                                ));
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video ID not found.')));
                                              }
                                            },
                                          ),
                                          if (watchedPercent > 0 && !isCompleted)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                              child: LinearProgressIndicator(
                                                value: watchedPercent / 100,
                                                backgroundColor: Colors.grey.shade200,
                                                color: Colors.purple.shade300,
                                                minHeight: 4,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    // Assignment
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.purple.shade100,
                                          child: Icon(Icons.assignment, color: Colors.purple.shade900),
                                        ),
                                        title: Text(contentData['title'] ?? 'No Title', style: const TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold)),
                                        subtitle: const Text("Assignment", style: TextStyle(fontFamily: "Sans", fontSize: 12)),
                                        trailing: const Icon(Icons.open_in_browser),
                                        onTap: () {
                                          if (contentData['url'] != null) {
                                            _launchUrl(contentData['url']);
                                          }
                                        },
                                      ),
                                    );
                                  }
                              },
                            ),
                    ),
                  ],
                ),
              );
            }
          );
        },
      ),
    );
  }
}
