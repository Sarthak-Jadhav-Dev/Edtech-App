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
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.purple.shade300,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.book_sharp),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Learner!",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "Sans",
                                ),
                              ),
                              FutureBuilder(
                                future: AuthService().getUserData(),
                                builder: (context, asyncSnapshot) {
                                  if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (!asyncSnapshot.hasData || asyncSnapshot.data!.data() == null) {
                                    return Center(child: Text("No user data found"));
                                  }
                                  var data = asyncSnapshot.data!.data() as Map<String, dynamic>;
                                  return Text(
                                    "${data['firstName']}",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: "Sans",
                                    ),
                                  );
                                }
                              ),
                            ],
                          ),
                          SizedBox(width: 50),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.purple.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.notifications),
                            ),
                          ),
                          SizedBox(width: 1),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.purple.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.person),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white60,
                          hintText: "Search Courses",
                          hintStyle: TextStyle(fontFamily: "Poppins"),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      width: 320,
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Solution, One",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "Poppins",
                                ),
                              ),
                              Text(
                                "Tap Away!",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "Poppins",
                                ),
                              ),
                              Text(
                                "Seamless, Fast and Reliable",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: "Sans",
                                ),
                              ),
                              Text(
                                "Services at your Fingertips",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: "Sans",
                                ),
                              ),
                              SizedBox(height: 7),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white70,
                                  side: BorderSide(
                                    color: Colors.white70,
                                    width: 1,
                                  ),
                                  shape: StadiumBorder(),
                                ),
                                onPressed: () {},
                                child: Text(
                                  "Explore",
                                  style: TextStyle(fontFamily: "Sans"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Continue Learning",
                      style: TextStyle(fontSize: 18, fontFamily: "Poppins"),
                    ),
                    MaterialButton(
                      onPressed: () {},
                      child: Text(
                        "View all>",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 190,
                        child: Image.asset("assets/images/HappyFaces.png"),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 190,
                        child: Image.asset("assets/images/HappyFaces.png"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Courses",
                      style: TextStyle(fontSize: 18, fontFamily: "Poppins"),
                    ),
                    MaterialButton(
                      onPressed: () {},
                      child: Text(
                        "View all>",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 190,
                        child: Image.asset("assets/images/HappyFaces.png"),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 190,
                        child: Image.asset("assets/images/HappyFaces.png"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pending Assignments",
                      style: TextStyle(fontSize: 18, fontFamily: "Poppins"),
                    ),
                    MaterialButton(
                      onPressed: () {},
                      child: Text(
                        "View all>",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 190,
                        child: Image.asset("assets/images/HappyFaces.png"),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 190,
                        child: Image.asset("assets/images/HappyFaces.png"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "And Much more...",
                  style: TextStyle(fontSize: 18, fontFamily: "Poppins"),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 150,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade200,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Text(
                              "Assignments",
                              style: TextStyle(fontFamily: "Sans"),
                            ),
                          ),
                        ),
                        Container(
                          width: 150,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade200,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Text(
                              "Today's Live Classes",
                              style: TextStyle(fontFamily: "Sans"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 150,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade200,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Text(
                              "Progress",
                              style: TextStyle(fontFamily: "Sans"),
                            ),
                          ),
                        ),
                        Container(
                          width: 150,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade200,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Text(
                              "Streak",
                              style: TextStyle(fontFamily: "Sans"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
