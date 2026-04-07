import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChildQuizInsights extends StatelessWidget {
  final String classId;
  final String childId;
  final String childName;

  const ChildQuizInsights({
    super.key,
    required this.classId,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('quiz_results')
          .where('studentId', isEqualTo: childId)
          .orderBy('submittedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 80, color: Colors.purple.shade200),
                const SizedBox(height: 16),
                const Text("No quizzes taken yet.", style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        final results = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final data = results[index].data() as Map<String, dynamic>;
            final percentage = (data['percentage'] as num?)?.toDouble() ?? 0.0;
            final timeTaken = data['timeTakenSeconds'] as int? ?? 0;
            final insights = data['aiInsights'] as Map<String, dynamic>?;

            final bool isGood = percentage >= 70;
            final Color scoreColor = isGood ? Colors.green : Colors.orange;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor: scoreColor.withOpacity(0.1),
                  child: Text(
                    "${percentage.toInt()}%",
                    style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text("Quiz Attempt", style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                subtitle: Text(
                  "Time taken: ${(timeTaken / 60).floor()}m ${timeTaken % 60}s",
                  style: const TextStyle(fontSize: 12),
                ),
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: insights == null
                        ? const Center(
                            child: Text(
                              "AI Insight is being generated...",
                              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                          )
                        : _buildInsightsView(insights),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInsightsView(Map<String, dynamic> insights) {
    final parentRemarks = insights['parentRemarks'] ?? "No remark available.";
    final coveredTopics = List<String>.from(insights['coveredTopics'] ?? []);
    final understoodTopics = List<String>.from(insights['understoodTopics'] ?? []);
    final focusTopics = List<String>.from(insights['focusTopics'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Buddy Remark
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.smart_toy, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  parentRemarks,
                  style: TextStyle(fontFamily: "Sans", color: Colors.blue.shade900, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (understoodTopics.isNotEmpty) ...[
          const Text("🌟 Strengths", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppins")),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: understoodTopics.map((t) => Chip(
              label: Text(t, style: TextStyle(color: Colors.green.shade800, fontSize: 12)),
              backgroundColor: Colors.green.shade50,
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],

        if (focusTopics.isNotEmpty) ...[
          const Text("🎯 Focus Needed", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppins")),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: focusTopics.map((t) => Chip(
              label: Text(t, style: TextStyle(color: Colors.orange.shade900, fontSize: 12)),
              backgroundColor: Colors.orange.shade50,
            )).toList(),
          ),
        ],
      ],
    );
  }
}
