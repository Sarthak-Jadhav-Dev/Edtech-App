import 'package:flutter/material.dart';

class TeacherQuizInsightsScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;
  final String quizTitle;

  const TeacherQuizInsightsScreen({
    super.key,
    required this.resultData,
    required this.quizTitle,
  });

  @override
  Widget build(BuildContext context) {
    final insights = resultData['aiInsights'] as Map<String, dynamic>?;
    final pct = (resultData['percentage'] as num?)?.toDouble() ?? 0.0;
    final timeTaken = resultData['timeTakenSeconds'] as int? ?? 0;
    final isGood = pct >= 70;
    final scoreColor = isGood ? Colors.green : Colors.orange;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Analytical Report", style: TextStyle(fontFamily: "Poppins", color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(resultData['studentName'] ?? 'Unknown Student', style: const TextStyle(fontFamily: "Poppins", fontSize: 24, fontWeight: FontWeight.bold)),
            Text(quizTitle, style: const TextStyle(fontFamily: "Sans", fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 20),

            // Base Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Score",
                    value: "${pct.toInt()}%",
                    icon: Icons.analytics,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    title: "Time Taken",
                    value: "${(timeTaken / 60).floor()}m ${timeTaken % 60}s",
                    icon: Icons.timer,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            const Text("AI Context & Analysis", style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            if (insights == null)
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
                child: const Center(
                  child: Text("Processing AI insights... Please check back in a few seconds.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ),
              )
            else ...[
              // Teacher remark 
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.indigo.shade400),
                        const SizedBox(width: 10),
                        Text("Automated Summary", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      insights['teacherRemarks'] ?? "No remark available",
                      style: TextStyle(fontFamily: "Sans", color: Colors.indigo.shade900, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              _buildTopicSection("Covered Topics", List<String>.from(insights['coveredTopics'] ?? []), Colors.grey),
              const SizedBox(height: 15),
              _buildTopicSection("Understood Topics", List<String>.from(insights['understoodTopics'] ?? []), Colors.green),
              const SizedBox(height: 15),
              _buildTopicSection("Focus Required", List<String>.from(insights['focusTopics'] ?? []), Colors.orange),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontFamily: "Poppins", fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontFamily: "Sans", fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTopicSection(String title, List<String> topics, MaterialColor themeColor) {
    if (topics.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold, color: themeColor.shade800)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: themeColor.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: themeColor.shade200),
            ),
            child: Text(t, style: TextStyle(fontSize: 13, color: themeColor.shade900)),
          )).toList(),
        ),
      ],
    );
  }
}
