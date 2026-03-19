import 'package:flutter/material.dart';
import 'package:kte/views/pages/home.dart';

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
          "Kids Trans EduTech",
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
            const DrawerHeader(child: Text("Welcome Learner!")),
            ListTile(
              title: Text("Home",style: textStyle,),
              leading: Icon(Icons.home),
              splashColor: Colors.purple.shade100,
              onTap: (){},
            ),
            ListTile(
              title: Text("Courses",style: textStyle,),
              leading: Icon(Icons.book),
              splashColor: Colors.purple.shade100,
              onTap: (){},
            ),
            ListTile(
              title: Text("Settings",style: textStyle,),
              leading: Icon(Icons.settings),
              splashColor: Colors.purple.shade100,
              onTap: (){},
            ),
            ListTile(
              title: Text("Achievements",style: textStyle,),
              leading: Icon(Icons.star),
              splashColor: Colors.purple.shade100,
              onTap: (){},
            ),
            ListTile(
              title: Text("Profile",style: textStyle,),
              leading: Icon(Icons.person),
              splashColor: Colors.purple.shade100,
              onTap: (){},
            ),
          ],
        ),
      ),
      body: const Home(),
    );
  }
}
