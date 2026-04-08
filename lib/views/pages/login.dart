import 'package:flutter/material.dart';
import 'package:kte/views/auth_pages/signin.dart';
import 'package:kte/views/auth_pages/signup.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Hero(
                tag: 'Hello',
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/HappyFaces.png',
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Welcome to KTE",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Empowering young minds to explore, create, and innovate through hands-on learning experiences.",
                      style: TextStyle(
                        fontFamily: "Sans",
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginForm()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: Colors.purple.shade900,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontFamily: "Sans",
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterForm()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        side: const BorderSide(
                            color: Colors.black54, width: 1),
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          fontFamily: "Sans",
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "By continuing, you confirm that you have read and agree to KTE’s Terms of Service and Privacy Policy, and consent to the collection and use of your information in accordance with these policies.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Sans",
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}