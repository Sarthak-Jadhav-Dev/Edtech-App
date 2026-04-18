import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:kte/views/teacher/create_course.dart';
import 'package:kte/views/teacher/class_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_services.dart';
import '../pages/home_section/shared_components.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String searchQuery = "";
  late final Future<DocumentSnapshot> _userDataFuture = AuthService().getUserData();
  late final Stream<QuerySnapshot> _classesStream = FirestoreService().getTeacherClasses(FirebaseAuth.instance.currentUser?.uid ?? '');

  @override
  void initState() {
    super.initState();
  }

  Widget _buildTeacherClassCard(Map<String, dynamic> classData, String classId, BuildContext context) {
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
              builder: (_) => ClassDetailScreen(classId: classId, classData: classData)
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.purpleAccent,
                  child: Icon(Icons.class_, color: Colors.white),
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
                  "Students: ${(classData['enrolledStudents'] as List?)?.length ?? 0}",
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

  Widget _buildAssignmentCard(Map<String, dynamic> assignment, BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 15),
      child: Card(
        elevation: 4,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.orangeAccent,
                child: Icon(Icons.assignment, color: Colors.white),
              ),
              const Spacer(),
              Text(
                assignment['title'] ?? 'Assignment',
                style: const TextStyle(fontFamily: "Poppins", fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                "Created Recently",
                style: const TextStyle(fontFamily: "Sans", fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
          );
        },
        backgroundColor: Colors.purple.shade900,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create Class", style: TextStyle(color: Colors.white, fontFamily: "Sans")),
      ),
      body: FutureBuilder(
        future: _userDataFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!asyncSnapshot.hasData || asyncSnapshot.data!.data() == null) {
            return const Center(child: Text("No user data found"));
          }
          var userData = asyncSnapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(
                  userData: userData, 
                  greetingPrefix: "Welcome Educator",
                  onSearchChanged: (val) {
                    setState(() {
                      searchQuery = val.trim().toLowerCase();
                    });
                  },
                ),
                
                StreamBuilder<QuerySnapshot>(
                  stream: _classesStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Error loading classes:\n${snapshot.error}", 
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontFamily: "Sans", fontSize: 14, color: Colors.red)),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator());
                    }
                    
                    final allClasses = snapshot.data?.docs.toList() ?? [];
                    final classes = allClasses.where((doc) {
                      if (searchQuery.isEmpty) {
                        return true;
                      }
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '').toString().toLowerCase();
                      return name.contains(searchQuery);
                    }).toList();
                    classes.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTime = aData['createdAt'] as Timestamp?;
                      final bTime = bData['createdAt'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return bTime.compareTo(aTime); 
                    });

                    final classIds = classes.map((d) => d.id).toList();

                    return Column(
                      children: [
                        SectionHeader(title: "Classes You Teach"),
                        if (classes.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("No classes created yet.\nTap + to create one!", 
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: "Sans", fontSize: 16)),
                          )
                        else
                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: classes.length,
                              itemBuilder: (context, index) {
                                final doc = classes[index];
                                return _buildTeacherClassCard(doc.data() as Map<String, dynamic>, doc.id, context);
                              },
                            ),
                          ),

                        SectionHeader(title: "Assignments Given"),
                        if (classes.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("Create a class to assign work.", style: TextStyle(fontFamily: "Sans")),
                          )
                        else
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: FirestoreService().getTeacherAssignments(classIds),
                            builder: (context, assignSnapshot) {
                              if (assignSnapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              final assignments = assignSnapshot.data ?? [];
                              if (assignments.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text("No assignments given yet.", style: TextStyle(fontFamily: "Sans")),
                                );
                              }
                              return SizedBox(
                                height: 140,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  itemCount: assignments.length,
                                  itemBuilder: (context, index) {
                                    return _buildAssignmentCard(assignments[index], context);
                                  },
                                ),
                              );
                            }
                          ),
                      ],
                    );
                  }
                ),
                
                const SizedBox(height: 80), 
              ],
            ),
          );
        }
      ),
    );
  }
}
