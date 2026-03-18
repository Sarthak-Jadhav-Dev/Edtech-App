import 'package:flutter/material.dart';
import 'package:kte/views/auth_pages/signin.dart';
import 'package:kte/services/app_state.dart';
import 'package:kte/views/auth_pages/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset("assets/images/HappyFaces.png"),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: ClipOval(
                      child: Hero(
                        tag: 'hello',
                        child: Image.asset(
                          "assets/images/Kids.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              "WELCOME",
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Ready to start your next big adventure?\nLog in to keep exploring!",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "Sans"),
            ),
            const SizedBox(height: 40),
            OutlinedButton(
              onPressed: () async {
                await AppState.setNotFirstTime();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginForm()),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 50),
                side: BorderSide(color: Colors.deepPurpleAccent.shade700, width: 1),
                shape: const StadiumBorder(),
                backgroundColor: Colors.deepPurpleAccent.shade100,
              ),
              child: const Text("Login", style: TextStyle(fontFamily: "Sans")),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () async {
                await AppState.setNotFirstTime();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterForm()),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 50),
                side: const BorderSide(color: Colors.black26, width: 1),
                shape: const StadiumBorder(),
              ),
              child: const Text("Register", style: TextStyle(fontFamily: "Sans")),
            ),
          ],
        ),
      ),
    );
  }
}
