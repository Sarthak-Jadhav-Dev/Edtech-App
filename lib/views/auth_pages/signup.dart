import 'package:flutter/material.dart';
import 'package:kte/views/pages/login.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final List<String> userTypes = ["Student", "Parent", "Teacher"];
  String selectedUserType = "Student";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  bottom: -440, // Increased to accommodate new fields
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        width: double.infinity,
                        height: 520, // Increased height
                        color: Colors.purple.shade50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                const SizedBox(height: 10),
                                // User Type Selection
                                Container(
                                  width: 300,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white60,
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(color: Colors.white54),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedUserType,
                                      isExpanded: true,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      items: userTypes.map((String type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(type, style: const TextStyle(fontFamily: "Sans")),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedUserType = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
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
                            const Text(
                              "Already have an account? Login",
                              style: TextStyle(
                                fontFamily: "Sans",
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 450),
          ],
        ),
      ),
    );
  }
}
