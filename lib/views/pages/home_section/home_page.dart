import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_services.dart';
import '../../../services/firestore_service.dart';
import '../../student/class_detail_screen.dart';
import '../../student/assignment_view_screen.dart';
import '../../student/progress_dashboard.dart';
import 'shared_components.dart';
import 'package:lottie/lottie.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String searchQuery = "";
  late final Future<DocumentSnapshot> _userDataFuture = AuthService()
      .getUserData();
  late final Stream<QuerySnapshot> _classesStream = FirestoreService()
      .getEnrolledClasses(uid, 'Student');

  @override
  void initState() {
    super.initState();
  }

  Widget _buildClassCard(
    Map<String, dynamic> classData,
    String classId,
    BuildContext context,
  ) {
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentClassDetailScreen(
                  classId: classId,
                  classData: classData,
                ),
              ),
            );
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
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildAssignmentCard(
    Map<String, dynamic> assignment,
    BuildContext context,
  ) {
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AssignmentViewScreen(
                  classId: assignment['classId'],
                  contentId: assignment['id'],
                  assignmentData: assignment,
                ),
              ),
            );
          },
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
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "Due soon", // For demo purposes as there is no due date in DB yet
                  style: const TextStyle(
                    fontFamily: "Sans",
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
            children: [
              DashboardHeader(
                userData: userData,
                greetingPrefix: "Welcome back",
                onSearchChanged: (val) {
                  setState(() {
                    searchQuery = val.trim().toLowerCase();
                  });
                },
              ),

              StreamBuilder<QuerySnapshot>(
                stream: _classesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    );
                  }

                  final allClasses = snapshot.data?.docs ?? [];
                  final classes = allClasses.where((doc) {
                    if (searchQuery.isEmpty) return true;
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();
                  final classIds = classes.map((d) => d.id).toList();

                  return Column(
                    children: [
                      SectionHeader(title: "Your Courses"),
                      if (classes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "You are not enrolled in any courses yet.",
                            style: TextStyle(fontFamily: "Sans"),
                          ),
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
                              return _buildClassCard(
                                doc.data() as Map<String, dynamic>,
                                doc.id,
                                context,
                              );
                            },
                          ),
                        ),

                      SectionHeader(title: "Pending Assignments"),
                      if (classes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "No pending assignments.",
                            style: TextStyle(fontFamily: "Sans"),
                          ),
                        )
                      else
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: FirestoreService().getPendingAssignments(
                            uid,
                            classIds,
                          ),
                          builder: (context, assignSnapshot) {
                            if (assignSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            final assignments = assignSnapshot.data ?? [];
                            if (assignments.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      child: Lottie.asset(
                                        'assets/lottie/all_caught_up.json',
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => const Padding(
                                          padding: EdgeInsets.only(bottom: 8.0),
                                          child: Icon(Icons.check_circle, size: 40, color: Colors.green),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "You're all caught up!",
                                      style: TextStyle(
                                        fontFamily: "Sans",
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return SizedBox(
                              height: 140,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                itemCount: assignments.length,
                                itemBuilder: (context, index) {
                                  return _buildAssignmentCard(
                                    assignments[index],
                                    context,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),

              SectionHeader(title: "Quick Links"),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickLinkButton(context, "Live Classes", () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Coming Soon! Live sessions integration is in progress.",
                          ),
                        ),
                      );
                    }),
                    _buildQuickLinkButton(context, "Progress", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProgressDashboard(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickLinkButton(
    BuildContext context,
    String text,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        width: 150,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "Sans",
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
