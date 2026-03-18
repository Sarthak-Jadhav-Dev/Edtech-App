import 'package:flutter/material.dart';
import 'package:kte/views/pages/home_section/home_page.dart';
import 'package:kte/views/pages/home_section/profile_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentScreen = 0;
  final List<Widget> screens = [
    const HomeSection(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: currentScreen,
            children: screens,
          ),
        ),
        NavigationBar(
          onDestinationSelected: (int value) {
            setState(() {
              currentScreen = value;
            });
          },
          selectedIndex: currentScreen,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Person'),
          ],
        ),
      ],
    );
  }
}
