import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kte/services/auth_services.dart';
import 'package:kte/views/pages/login.dart';
import 'package:kte/views/widget_tree.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> userTypes = ["Student", "Parent", "Teacher"];
  String selectedUserType = "Student";
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
          child: Column(
            children: [
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Sans",
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                hintText: "First Name",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                hintText: "Last Name",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: selectedUserType,
                        items: userTypes.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedUserType = val!;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : OutlinedButton(
                              onPressed: () async {
                                final email = _emailController.text.trim();
                                final password = _passwordController.text.trim();
                                final firstName = _firstNameController.text
                                    .trim();
                                final lastName = _lastNameController.text.trim();
                                if (email.isEmpty ||
                                    password.isEmpty ||
                                    firstName.isEmpty ||
                                    lastName.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please fill all fields"),
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _isLoading = true;
                                });
                                final user = await AuthService().signUp(
                                  email: email,
                                  password: password,
                                  firstName: firstName,
                                  lastName: lastName,
                                  userType: selectedUserType,
                                );
                                setState(() {
                                  _isLoading = false;
                                });
                                if (user != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const WidgetTree(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Registration Failed, Please Try Again"),
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: Colors.purple.shade900,
                              ),
                              child: const Text(
                                "Register",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                      const SizedBox(
                        width: 300,
                        child: Text(
                          "Registering in for our Services means you agree to our Terms of Service and Privacy Policy",
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
            ],
          ),
        ),
      ),
    );
  }
}
