import 'package:flutter/material.dart';
import 'package:kte/services/auth_services.dart';
import 'package:kte/views/pages/home.dart';
import 'package:kte/views/student/course_list.dart';
import 'package:kte/views/student/achievements_screen.dart';
import 'package:kte/views/student/link_parent_screen.dart';
import 'package:kte/views/teacher/teacher_dashboard.dart';
import 'package:kte/views/parent/parent_dashboard.dart';
import 'package:kte/views/pages/login.dart';
import 'package:kte/views/student/chatbot/chatbot_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:kte/views/common/gamification/global_reward_overlay.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final textStyle = const TextStyle(
    fontFamily: "Sans",
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Colors.black,
  );

  String? userType;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserType();
  }

  Future<void> _fetchUserType() async {
    try {
      final doc = await AuthService().getUserData();
      if (doc.exists) {
        setState(() {
          userType = doc['userType'];
          isLoading = false;
        });
        
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && userType == 'Student') {
          // Update daily login streak asynchronously for students
          FirestoreService().updateLoginStreak(user.uid);
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget bodyWidget;
    Widget? floatingActionButton;
    List<Widget> drawerItems = [];

    // Base header for Drawer
    Widget drawerHeader = DrawerHeader(
      decoration: BoxDecoration(color: Colors.purple.shade300),
      child: Padding(
        padding: const EdgeInsets.all(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userType == 'Teacher' ? "What to Teach" : "What to Learn",
                  style: const TextStyle(fontSize: 20, fontFamily: "Sans"),
                ),
                const Text("Today ?", style: TextStyle(fontSize: 25, fontFamily: "Sans")),
                const SizedBox(height: 20),
              ],
            ),
          ),
        )
      ),
    );

    drawerItems.add(drawerHeader);
    drawerItems.add(
      ListTile(
        title: Text("Home", style: textStyle),
        leading: const Icon(Icons.home),
        splashColor: Colors.purple.shade100,
        onTap: () {
          Navigator.pop(context);
        },
      )
    );

    if (userType == 'Teacher') {
      bodyWidget = const TeacherDashboard();
      drawerItems.addAll([
        ListTile(
          title: Text("My Classes", style: textStyle),
          leading: const Icon(Icons.class_),
          splashColor: Colors.purple.shade100,
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ]);
    } else if (userType == 'Parent') {
      bodyWidget = const ParentDashboard();
      drawerItems.addAll([
        ListTile(
          title: Text("My Children", style: textStyle),
          leading: const Icon(Icons.child_care),
          splashColor: Colors.purple.shade100,
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ]);
    } else {
      // Default / Student
      bodyWidget = const Home();
      drawerItems.addAll([
        ListTile(
          title: Text("Courses", style: textStyle),
          leading: const Icon(Icons.book),
          splashColor: Colors.purple.shade100,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseListScreen()));
          },
        ),
        ListTile(
          title: Text("Link Parent", style: textStyle),
          leading: const Icon(Icons.link),
          splashColor: Colors.purple.shade100,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LinkParentScreen()));
          },
        ),
        ListTile(
          title: Text("Achievements", style: textStyle),
          leading: const Icon(Icons.star),
          splashColor: Colors.purple.shade100,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen()));
          },
        ),
      ]);
      
      floatingActionButton = FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
        },
        backgroundColor: Colors.orangeAccent,
        icon: const Icon(Icons.smart_toy, color: Colors.white),
        label: const Text("AI Buddy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }

    drawerItems.addAll([
      ListTile(
        title: Text("Settings", style: textStyle),
        leading: const Icon(Icons.settings),
        splashColor: Colors.purple.shade100,
        onTap: () {},
      ),
      ListTile(
        title: Text("Logout", style: textStyle),
        leading: const Icon(Icons.logout),
        splashColor: Colors.purple.shade100,
        onTap: () async {
          await AuthService().logout();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (_) => const Login()), 
              (route) => false
            );
          }
        },
      ),
    ]);

    return GlobalRewardOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Kids EduTech",
            style: TextStyle(
              fontFamily: "Sans",
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            children: drawerItems,
          ),
        ),
        body: bodyWidget,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
