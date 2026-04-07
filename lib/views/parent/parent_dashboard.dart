import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:kte/views/parent/child_class_detail.dart';

import 'package:kte/services/auth_services.dart';
import '../pages/home_section/shared_components.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  Widget _buildChildClassCard(Map<String, dynamic> classData, String classId, BuildContext context, String childId, String childName) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 15),
      child: Card(
        elevation: 4,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => ChildClassDetailScreen(classId: classId, classData: classData, childId: childId, childName: childName)
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.purpleAccent,
                  child: Icon(Icons.book, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  classData['name'] ?? 'Unnamed',
                  style: const TextStyle(fontFamily: "Poppins", fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "Subject: ${classData['subject']}",
                  style: const TextStyle(fontFamily: "Sans", fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildXPChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontFamily: "Sans", fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: AuthService().getUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text("Parent profile not found"));
        }

        final data = userSnapshot.data!.data() as Map<String, dynamic>;
        final childIds = (data['linkedChildIds'] as List<dynamic>?) ?? [];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(userData: data, greetingPrefix: "Welcome Parent"),
              
              if (childIds.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: Text(
                      "No children linked yet.\nWait for your child to link to your account.",
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontFamily: "Sans", fontSize: 16)
                    ),
                  ),
                )
              else
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: FirestoreService().getLinkedChildren(childIds),
                  builder: (context, childrenSnapshot) {
                    if (childrenSnapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
                    }

                    final children = childrenSnapshot.data ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children.map((child) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionHeader(title: "${child['firstName']}'s Courses", onSeeAll: () {}),
                              
                              // XP / Level display
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                child: StreamBuilder<DocumentSnapshot>(
                                  stream: FirestoreService().getUserStream(child['uid']),
                                  builder: (context, xpSnap) {
                                    final xpData = xpSnap.data?.data() as Map<String, dynamic>? ?? {};
                                    final xp = (xpData['xp'] as int?) ?? 0;
                                    final level = (xpData['level'] as int?) ?? 1;
                                    final quizzes = (xpData['quizzesTaken'] as int?) ?? 0;
                                    return Row(
                                      children: [
                                        _buildXPChip(Icons.bolt, "$xp XP", Colors.amber),
                                        const SizedBox(width: 8),
                                        _buildXPChip(Icons.shield, "Level $level", Colors.purple),
                                        const SizedBox(width: 8),
                                        _buildXPChip(Icons.quiz, "$quizzes Quizzes", Colors.blue),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 5),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirestoreService().getEnrolledClasses(child['uid'], 'Student'),
                                builder: (context, classSnapshot) {
                                  if (classSnapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (!classSnapshot.hasData || classSnapshot.data!.docs.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                                      child: Text("Not enrolled in any courses.", style: TextStyle(fontFamily: "Sans")),
                                    );
                                  }

                                  final classes = classSnapshot.data!.docs;

                                  return SizedBox(
                                    height: 140,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      itemCount: classes.length,
                                      itemBuilder: (context, index) {
                                        final doc = classes[index];
                                        return _buildChildClassCard(doc.data() as Map<String, dynamic>, doc.id, context, child['uid'], child['firstName']);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
