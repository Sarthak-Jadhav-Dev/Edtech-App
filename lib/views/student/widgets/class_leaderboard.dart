import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/firestore_service.dart';

class ClassLeaderboard extends StatelessWidget {
  final String classId;

  const ClassLeaderboard({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirestoreService().getClassLeaderboard(classId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final students = snapshot.data!;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.amber.shade100, shape: BoxShape.circle),
                    child: const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Top Learners",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...List.generate(students.length, (index) {
                final student = students[index];
                final isMe = student['uid'] == currentUid;
                final xp = student['xp'] ?? 0;
                final name = "${student['firstName'] ?? 'Student'} ${student['lastName'] ?? ''}".trim();

                Color badgeColor;
                if (index == 0) { badgeColor = Colors.amber; }
                else if (index == 1) { badgeColor = Colors.grey.shade400; }
                else if (index == 2) { badgeColor = Colors.brown.shade300; }
                else { badgeColor = Colors.blue.shade200; }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.purple.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: isMe ? Border.all(color: Colors.purple.shade200, width: 2) : Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "#${index + 1}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isMe ? Colors.purple.shade700 : Colors.black54),
                      ),
                      const SizedBox(width: 16),
                      Icon(index < 3 ? Icons.military_tech : Icons.star, color: badgeColor, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          isMe ? "You" : name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isMe ? Colors.purple.shade900 : Colors.black87,
                            fontFamily: "Sans",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "$xp XP",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: index == 0 ? Colors.amber.shade800 : Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
