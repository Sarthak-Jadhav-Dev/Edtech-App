import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'child_quiz_insights.dart'; // We will create this next

class ChildClassDetailScreen extends StatelessWidget {
  final String classId;
  final Map<String, dynamic> classData;
  final String childId;
  final String childName;

  const ChildClassDetailScreen({
    super.key,
    required this.classId,
    required this.classData,
    required this.childId,
    required this.childName,
  });

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text("$childName's Course", style: TextStyle(fontFamily: "Poppins", fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 1,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
          bottom: const TabBar(
            labelColor: Colors.purple,
            indicatorColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: "Content"),
              Tab(icon: Icon(Icons.analytics), text: "Insights"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildContentTab(context),
            ChildQuizInsights(classId: classId, childId: childId, childName: childName), 
          ],
        ),
      ),
    );
  }

  Widget _buildContentTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Subject: ${classData['subject']}", style: TextStyle(fontSize: 18, fontFamily: "Sans", fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text("${classData['description']}", style: TextStyle(fontFamily: "Sans", color: Theme.of(context).colorScheme.onSurface.withAlpha(153))),
          const SizedBox(height: 20),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getClassContent(classId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No content available.", style: TextStyle(fontFamily: "Sans")));
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
                        title: Text(contentData['title'] ?? 'No Title', style: TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        subtitle: Text(isVideo ? "Video Link" : "Assignment", style: TextStyle(fontFamily: "Sans", fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withAlpha(153))),
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
    );
  }
}
