import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:kte/views/parent/child_class_detail.dart';

import 'package:kte/services/auth_services.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

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

        if (childIds.isEmpty) {
          return const Center(
            child: Text("No children linked yet.\nWait for your child to link to your account.",
                textAlign: TextAlign.center, style: TextStyle(fontFamily: "Sans", fontSize: 16)),
          );
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: FirestoreService().getLinkedChildren(childIds),
          builder: (context, childrenSnapshot) {
            if (childrenSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final children = childrenSnapshot.data ?? [];

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Child: \${child['firstName']} \${child['lastName']}",
                        style: const TextStyle(fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirestoreService().getEnrolledClasses(child['uid'], 'Student'),
                      builder: (context, classSnapshot) {
                        if (classSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!classSnapshot.hasData || classSnapshot.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Text("Not enrolled in any courses.", style: TextStyle(fontFamily: "Sans")),
                          );
                        }

                        final classes = classSnapshot.data!.docs;

                        return Column(
                          children: classes.map((doc) {
                            final classData = doc.data() as Map<String, dynamic>;
                            return Card(
                              elevation: 2,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const CircleAvatar(backgroundColor: Colors.purpleAccent, child: Icon(Icons.book, color: Colors.white)),
                                title: Text(classData['name'] ?? 'Unnamed', style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
                                subtitle: Text("Subject: \${classData['subject']}", style: const TextStyle(fontFamily: "Sans")),
                                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.purple),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => ChildClassDetailScreen(classId: doc.id, classData: classData)
                                  ));
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
