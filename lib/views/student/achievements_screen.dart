import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kte/services/firestore_service.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  IconData _getBadgeIcon(String iconName) {
    switch (iconName) {
      case 'quiz': return Icons.quiz;
      case 'star': return Icons.star;
      case 'trophy': return Icons.emoji_events;
      case 'bolt': return Icons.bolt;
      case 'school': return Icons.school;
      case 'speed': return Icons.speed;
      default: return Icons.military_tech;
    }
  }

  Color _getBadgeColor(String iconName) {
    switch (iconName) {
      case 'quiz': return Colors.blue;
      case 'star': return Colors.amber;
      case 'trophy': return Colors.orange;
      case 'bolt': return Colors.yellow.shade700;
      case 'school': return Colors.purple;
      case 'speed': return Colors.green;
      default: return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("My Achievements", style: TextStyle(fontFamily: "Poppins", color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirestoreService().getUserStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No data found", style: TextStyle(fontFamily: "Sans")));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final xp = (data['xp'] as int?) ?? 0;
          final level = (data['level'] as int?) ?? 1;
          final quizzesTaken = (data['quizzesTaken'] as int?) ?? 0;
          final perfectScores = (data['perfectScores'] as int?) ?? 0;
          final badges = List<Map<String, dynamic>>.from(data['badges'] ?? []);
          final xpProgress = xp % 100;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Level Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade900, Colors.deepPurple.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.amber.shade400,
                          child: Text("$level", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "Poppins")),
                        ),
                        const SizedBox(height: 10),
                        const Text("Level", style: TextStyle(fontSize: 14, color: Colors.white70, fontFamily: "Sans")),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bolt, color: Colors.amber, size: 22),
                            const SizedBox(width: 5),
                            Text("$xp XP Total", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "Poppins")),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Level $level", style: const TextStyle(color: Colors.white70, fontFamily: "Sans", fontSize: 12)),
                                Text("Level ${level + 1}", style: const TextStyle(color: Colors.white70, fontFamily: "Sans", fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            LinearProgressIndicator(
                              value: xpProgress / 100,
                              backgroundColor: Colors.white24,
                              color: Colors.amber,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(height: 5),
                            Text("$xpProgress / 100 XP to next level", style: const TextStyle(color: Colors.white54, fontFamily: "Sans", fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Stats Row
                Row(
                  children: [
                    Expanded(child: _buildStatCard("Quizzes", "$quizzesTaken", Icons.quiz, Colors.blue)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard("Perfect", "$perfectScores", Icons.star, Colors.amber)),
                  ],
                ),

                const SizedBox(height: 25),

                // Badges Section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Badges Earned", style: TextStyle(fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 15),

                if (badges.isEmpty)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: const Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Icon(Icons.military_tech, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("No badges yet!", style: TextStyle(fontFamily: "Sans", fontSize: 16, color: Colors.grey)),
                          Text("Take quizzes to earn your first badge!", style: TextStyle(fontFamily: "Sans", fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      final iconName = badge['icon'] ?? 'star';
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [_getBadgeColor(iconName).withValues(alpha: 0.1), _getBadgeColor(iconName).withValues(alpha: 0.05)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_getBadgeIcon(iconName), size: 36, color: _getBadgeColor(iconName)),
                              const SizedBox(height: 8),
                              Text(badge['name'] ?? '', style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontFamily: "Poppins", fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(fontFamily: "Sans", fontSize: 13, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
