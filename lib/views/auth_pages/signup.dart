import 'package:flutter/material.dart';
import 'package:kte/views/pages/login.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final greyOutline = OutlineInputBorder(
    borderRadius: BorderRadius.circular(40),
    borderSide: const BorderSide(color: Colors.white54),
  );

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
                  bottom: -400,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Container(
                      width: double.infinity,
                      height: 460,
                      color: Colors.purple.shade50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Register",style: TextStyle(fontFamily: "Poppins",fontSize: 20,fontWeight: FontWeight.bold),),
                          SizedBox(
                            height: 3,
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(300, 50),
                              side: const BorderSide(color: Colors.black, width: 1),
                              shape: const StadiumBorder(),
                              backgroundColor: Colors.purple.shade50,
                            ),
                            child: const Text(
                              "Sign in with Google",
                              style: TextStyle(fontFamily: "Sans"),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text("or", style: TextStyle(fontFamily: "Sans")),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              SizedBox(
                                width: 300,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(
                                      width: 148,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white60,
                                          hintText: "First Name",
                                          hintStyle: TextStyle(
                                            fontFamily: "Sans",
                                            color: Colors.black54,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white60),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(40),
                                              topLeft: Radius.circular(40),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 148,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white60,
                                          hintText: "Last Name",
                                          hintStyle: TextStyle(
                                            fontFamily: "Sans",
                                            color: Colors.black54,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white60),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(40),
                                              bottomRight: Radius.circular(40),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                              "Register",
                              style: TextStyle(
                                fontFamily: "Sans",
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 300,
                            child: const Text(
                              "Registering for our Services means you agree to our Terms of Service and Privacy Policy",
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
