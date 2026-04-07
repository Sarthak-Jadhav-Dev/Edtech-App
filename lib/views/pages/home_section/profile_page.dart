import 'package:flutter/material.dart';
import 'package:kte/services/auth_services.dart';
import 'package:kte/services/theme_notifier.dart';
import '../login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Widget buildTile(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(
            title,
            style: TextStyle(fontFamily: "Poppins"),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().getUserData(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!asyncSnapshot.hasData || asyncSnapshot.data!.data() == null) {
          return Center(child: Text("No user data found"));
        }
        var data = asyncSnapshot.data!.data() as Map<String, dynamic>;
        return Scaffold(
          backgroundColor: Colors.purple.shade50,
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.purple.shade100,
                          child: Icon(Icons.person, size: 50, color: Colors.purple),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "${data['firstName']} ${data['lastName']}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "${data['email']}",
                          style: TextStyle(
                            color: Colors.black54,
                            fontFamily: "Sans",
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "${data['userType']}",
                          style: TextStyle(
                            color: Colors.black45,
                            fontFamily: "Sans",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (context, themeMode, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SwitchListTile(
                          secondary: const Icon(Icons.palette, color: Colors.black87),
                          title: const Text("Dark Mode", style: TextStyle(fontFamily: "Poppins", color: Colors.black87)),
                          value: themeMode == ThemeMode.dark,
                          activeColor: Colors.purple,
                          onChanged: (bool value) {
                            toggleTheme(value);
                          },
                        ),
                      ),
                    );
                  }
                ),

                const SizedBox(height: 10),

                buildTile(Icons.security, "Application Security"),
                buildTile(Icons.lock, "Change Password"),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton(
                    onPressed: () {
                      AuthService().logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => Login()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: Colors.black54),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      "Log Out",
                      style: TextStyle(fontFamily: "Sans"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
