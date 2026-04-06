import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentClassDetailScreen extends StatelessWidget {
  final String classId;
  final Map<String, dynamic> classData;

  const StudentClassDetailScreen({super.key, required this.classId, required this.classData});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch \$urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: Text(classData['name'] ?? 'Course Detail', style: const TextStyle(fontFamily: "Poppins")),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Subject: \${classData['subject']}", style: const TextStyle(fontSize: 18, fontFamily: "Sans", fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("\${classData['description']}", style: const TextStyle(fontFamily: "Sans", color: Colors.black54)),
            const SizedBox(height: 20),
            const Text("Course Content", style: TextStyle(fontSize: 20, fontFamily: "Poppins", fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getClassContent(classId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No content available yet.", style: TextStyle(fontFamily: "Sans")));
                  }

                  final contents = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      final contentData = contents[index].data() as Map<String, dynamic>;
                      final isVideo = contentData['type'] == 'video';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple.shade100,
                            child: Icon(isVideo ? Icons.play_circle_fill : Icons.assignment, color: Colors.purple.shade900),
                          ),
                          title: Text(contentData['title'] ?? 'No Title', style: const TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold)),
                          subtitle: Text(isVideo ? "Video Link" : "Google Form / Assignment", style: const TextStyle(fontFamily: "Sans", fontSize: 12)),
                          trailing: const Icon(Icons.open_in_browser),
                          onTap: () {
                            if (contentData['url'] != null) {
                              _launchUrl(contentData['url']);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
