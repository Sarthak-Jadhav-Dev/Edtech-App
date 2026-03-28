import 'package:flutter/material.dart';
import 'package:kte/views/pages/home.dart';
import 'package:kte/views/student/course_list.dart';
import 'package:kte/views/student/achievements_screen.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple.shade300),
              child: Padding(
                padding: const EdgeInsets.all(0.1),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("What to Learn",style: TextStyle(fontSize:20,fontFamily: "Sans"),),
                        Text("Today ?",style: TextStyle(fontSize:25,fontFamily: "Sans"),),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ),
            ListTile(
              title: Text("Home", style: textStyle),
              leading: const Icon(Icons.home),
              splashColor: Colors.purple.shade100,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Courses", style: textStyle),
              leading: const Icon(Icons.book),
              splashColor: Colors.purple.shade100,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseListScreen()));
              },
            ),
            ListTile(
              title: Text("Assignments", style: textStyle),
              leading: const Icon(Icons.assignment),
              splashColor: Colors.purple.shade100,
              onTap: () {
                // To be implemented
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
            ListTile(
              title: Text("Leaderboard", style: textStyle),
              leading: const Icon(Icons.leaderboard),
              splashColor: Colors.purple.shade100,
              onTap: () {
                // To be implemented
              },
            ),
            ListTile(
              title: Text("Settings", style: textStyle),
              leading: const Icon(Icons.settings),
              splashColor: Colors.purple.shade100,
              onTap: () {},
            ),
            ListTile(
              title: Text("Profile", style: textStyle),
              leading: const Icon(Icons.person),
              splashColor: Colors.purple.shade100,
              onTap: () {},
            ),
          ],
        ),
      ),
      body: const Home(),
    );
  }
}
