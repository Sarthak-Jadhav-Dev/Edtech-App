import 'package:flutter/material.dart';
import '../../../services/auth_services.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.deepPurpleAccent.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome,",
                            style: TextStyle(fontFamily: "Sans"),
                          ),
                          Text(
                            "Sarthak !",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Sans",
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(Icons.search),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.deepPurpleAccent.shade100,
                width: double.infinity,
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Continue Learning Today...",
                        style: TextStyle(fontFamily: "Sans", fontSize: 20),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: Container(
                              height: 50,
                              width: 120,
                              color: Colors.deepPurpleAccent.shade700,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.pages, color: Colors.white),
                                  Text(
                                    "Learn",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () async{
                              await _authService.logout();
                            },
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                            ),
                            child: Text("Logout"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
