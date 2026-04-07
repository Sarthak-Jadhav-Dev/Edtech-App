import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String greetingPrefix;

  const DashboardHeader({super.key, required this.userData, this.greetingPrefix = "Welcome"});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.book_sharp, color: Colors.white),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$greetingPrefix, ${userData['userType']}!",
                            style: const TextStyle(fontSize: 15, fontFamily: "Sans", color: Colors.white70),
                          ),
                          Text(
                            "${userData['firstName']}",
                            style: const TextStyle(fontSize: 22, fontFamily: "Sans", color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor.withOpacity(0.9),
                    hintText: "Search Courses",
                    hintStyle: const TextStyle(fontFamily: "Poppins"),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Your Solution, One", style: TextStyle(fontSize: 20, fontFamily: "Poppins", color: Colors.white)),
                          const Text("Tap Away!", style: TextStyle(fontSize: 20, fontFamily: "Poppins", color: Colors.white)),
                          const Text("Seamless, Fast and Reliable", style: TextStyle(fontSize: 12, fontFamily: "Sans", color: Colors.white70)),
                          const Text("Services at your Fingertips", style: TextStyle(fontSize: 12, fontFamily: "Sans", color: Colors.white70)),
                          const SizedBox(height: 7),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              side: const BorderSide(color: Colors.white, width: 1),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () {},
                            child: const Text("Explore", style: TextStyle(fontFamily: "Sans", color: Colors.white)),
                          ),
                        ],
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

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const SectionHeader({super.key, required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: onSeeAll,
            child: const Text("View all>", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
