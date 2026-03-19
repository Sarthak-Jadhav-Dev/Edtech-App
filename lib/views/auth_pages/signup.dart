import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kte/views/pages/login.dart';
import 'package:kte/services/auth_services.dart';

import '../../services/app_state.dart';
import '../widget_tree.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
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
                    horizontal: 20, vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Register",
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
                              color: Colors.black, width: 1),
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.purple.shade50,
                        ),
                        child: const Text(
                          "Sign in with Google",
                          style: TextStyle(fontFamily: "Sans"),
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Text("or"),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 300,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstName,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white60,
                                  hintText: "First Name",
                                  hintStyle: TextStyle(
                                    fontFamily: "Sans",
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      bottomLeft: Radius.circular(40),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty) {
                                    return "Enter first name";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _lastName,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white60,
                                  hintText: "Last Name",
                                  hintStyle: TextStyle(
                                    fontFamily: "Sans"
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(40),
                                      bottomRight: Radius.circular(40),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty) {
                                    return "Enter last name";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// EMAIL
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white60,
                            hintText: "Email",
                            hintStyle: TextStyle(
                              fontFamily: "Sans"
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
                              return "Enter email";
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
                            hintStyle: TextStyle(
                              fontFamily: "Sans"
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
                              return "Enter password";
                            }
                            if (value.length < 6) {
                              return "Min 6 characters";
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// REGISTER BUTTON
                      OutlinedButton(
                        onPressed: () async{
                          if (!_formKey.currentState!.validate()) return;

                          final user = await _authService.signUp(
                            _email.text.trim(),
                            _password.text.trim(),
                          );

                          if (user != null) {
                            // ✅ Mark app as not first time
                            await AppState.setNotFirstTime();

                            if (!mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => WidgetTree()),
                            );
                          } else {
                            // ❌ Error
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Registration Failed")),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(300, 50),
                          shape: const StadiumBorder(),
                          backgroundColor:
                          Colors.purple.shade900,
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const SizedBox(
                        width: 300,
                        child: Text(
                          "Registering means you agree to Terms & Privacy Policy",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black54,
                            fontFamily: "Sans"
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}