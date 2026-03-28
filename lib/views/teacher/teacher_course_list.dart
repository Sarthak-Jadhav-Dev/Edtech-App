import 'package:flutter/material.dart';
import 'package:kte/views/teacher/create_course.dart';

class TeacherCourseListScreen extends StatelessWidget {
  const TeacherCourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateCourseScreen()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.book),
            title: Text("Advanced Phonics"),
            subtitle: Text("120 Students Enrolled"),
            trailing: Icon(Icons.edit),
          ),
          ListTile(
            leading: Icon(Icons.calculate),
            title: Text("Math for Toddlers"),
            subtitle: Text("85 Students Enrolled"),
            trailing: Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
