import 'package:flutter/material.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressDashboard extends StatelessWidget {
  const ProgressDashboard({super.key});

  String _getMotivationalText(double percentage) {
    if (percentage == 0) return "Big journey ahead! Let's start with one video today.";
    if (percentage < 20) return "Great start! Every small step counts on your learning path.";
    if (percentage < 50) return "Keep going! You're making steady progress through your courses.";
    if (percentage < 80) return "You're a star! Just a few more lessons left to completion.";
    if (percentage < 100) return "Almost there, Champion! Finish strong and claim your mastery!";
    return "Yeah Champion! You have completed everything! You are elite!";
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("Learning Journey", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: FirestoreService().getOverallProgressStats(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = snapshot.data ?? {'total': 0, 'completed': 0, 'percentage': 0.0, 'classCount': 0};
          final percentage = (stats['percentage'] as num).toDouble();
          final completed = stats['completed'] as int;
          final total = stats['total'] as int;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Top Motivation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade900, Colors.purple.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: CircularProgressIndicator(
                              value: (percentage / 100).clamp(0.0, 1.0),
                              strokeWidth: 12,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              color: Colors.white,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                "${percentage.toStringAsFixed(0)}%",
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                              ),
                              const Text(
                                "Overall",
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Text(
                        _getMotivationalText(percentage),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Sans", fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        context,
                        "Lessons",
                        "$completed / $total",
                        Icons.library_books,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildStatTile(
                        context,
                        "Classes",
                        "${stats['classCount']}",
                        Icons.school,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildStatTile(
                  context,
                  "Completion Status",
                  percentage >= 100 ? "Mastered" : "In Progress",
                  Icons.verified_user,
                  percentage >= 100 ? Colors.green : Colors.amber,
                  fullWidth: true,
                ),
                
                const SizedBox(height: 40),
                const Text(
                  "Every minute of learning makes you smarter! 🧠",
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatTile(BuildContext context, String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      // width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: fullWidth ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: "Sans")),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Poppins")),
        ],
      ),
    );
  }
}
