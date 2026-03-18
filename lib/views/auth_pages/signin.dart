import 'package:flutter/material.dart';
import 'package:kte/views/pages/login.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
            );
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: 'Hello',
                  child: Image.asset('assets/images/HappyFaces.png'),
                ),
                Positioned(
                  bottom: -370,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Container(
                      width: double.infinity,
                      height: 420,
                      color: Colors.purple.shade50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Login",style: TextStyle(fontFamily: "Poppins",fontSize: 20,fontWeight: FontWeight.bold),),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(300, 50),
                              side: const BorderSide(color: Colors.black, width: 1),
                              shape: const StadiumBorder(),
                              backgroundColor: Colors.purple.shade50,
                            ),
                            child: const Text(
                              "Log in with Google",
                              style: TextStyle(fontFamily: "Sans"),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text("or", style: TextStyle(fontFamily: "Sans")),
                          Column(
                            children: [
                              const SizedBox(height: 5),
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white60,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: const BorderSide(color: Colors.white54),
                                    ),
                                    hintText: "Email",
                                    hintStyle: const TextStyle(
                                      fontFamily: "Sans",
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white60,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: const BorderSide(color: Colors.white54),
                                    ),
                                    hintText: "Password",
                                    hintStyle: const TextStyle(
                                      fontFamily: "Sans",
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(300, 50),
                              side: const BorderSide(color: Colors.black54, width: 1),
                              shape: const StadiumBorder(),
                              backgroundColor: Colors.purple.shade900,
                            ),
                            child: const Text(
                              "Log in",
                              style: TextStyle(
                                fontFamily: "Sans",
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 300,
                            child: const Text(
                              "Logging in for our Services means you agree to our Terms of Service and Privacy Policy",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Sans",
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 350),
          ],
        ),
      ),
    );
  }
}
