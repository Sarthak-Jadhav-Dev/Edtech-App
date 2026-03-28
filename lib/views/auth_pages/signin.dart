import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kte/views/pages/login.dart';
import 'package:kte/services/auth_services.dart';

import '../../services/app_state.dart';
import '../widget_tree.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Get Started..",style: TextStyle(fontFamily: "Poppins"),),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Hero(
                tag: 'Hello',
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/HappyFaces.png',
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(300, 50),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.purple.shade50,
                      ),
                      child: const Text(
                        "Log in with Google",
                        style: TextStyle(fontFamily: "Sans"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text("or",
                        style: TextStyle(fontFamily: "Sans")),

                    const SizedBox(height: 10),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextFormField(
                              controller: _email,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white60,
                                hintText: "Email",
                                hintStyle: const TextStyle(
                                  fontFamily: "Sans",
                                  color: Colors.black54,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(40),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: 300,
                            child: TextFormField(
                              controller: _password,
                              obscureText: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white60,
                                hintText: "Password",
                                hintStyle: const TextStyle(
                                  fontFamily: "Sans",
                                  color: Colors.black54,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(40),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),
                    OutlinedButton(
                      onPressed: () async{
                        if (!_formKey.currentState!.validate()) return;

                        final user = await _authService.login(
                          _email.text.trim(),
                          _password.text.trim(),
                        );

                        if (user != null) {
                          await AppState.setNotFirstTime();

                          if (!mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => WidgetTree()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please check your credentials")),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(300, 50),
                        side: const BorderSide(
                          color: Colors.black54,
                          width: 1,
                        ),
                        shape: const StadiumBorder(),
                        backgroundColor:
                        Colors.purple.shade900,
                      ),
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          fontFamily: "Sans",
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const SizedBox(
                      width: 300,
                      child: Text(
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
            ],
          ),
        ),
      ),
    );
  }
}