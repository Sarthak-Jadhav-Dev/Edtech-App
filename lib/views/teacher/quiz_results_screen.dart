import 'package:flutter/material.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:kte/views/teacher/teacher_quiz_insights.dart';

class QuizResultsScreen extends StatelessWidget {
  final String classId;
  final String quizId;
  final String quizTitle;

  const QuizResultsScreen({super.key, required this.classId, required this.quizId, required this.quizTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: Text(quizTitle, style: const TextStyle(fontFamily: "Poppins", color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: FirestoreService().getQuizResultsForQuiz(classId, quizId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No submissions yet.", style: TextStyle(fontFamily: "Sans", fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          final results = snapshot.data!;
          // Sort by percentage descending
          results.sort((a, b) => (b['percentage'] as num).compareTo(a['percentage'] as num));

          return Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.purple.shade100,
                          radius: 30,
                          child: Icon(Icons.people, color: Colors.purple.shade900, size: 30),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${results.length} Submissions", style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 18)),
                              Text(
                                "Avg: ${(results.fold<double>(0, (sum, r) => sum + (r['percentage'] as num).toDouble()) / results.length).toStringAsFixed(1)}%",
                                style: TextStyle(fontFamily: "Sans", color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Student Scores", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final r = results[index];
                      final pct = (r['percentage'] as num).toDouble();
                      final isGood = pct >= 70;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => TeacherQuizInsightsScreen(
                              resultData: r,
                              quizTitle: quizTitle,
                            )
                          ));
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isGood ? Colors.green.shade100 : Colors.orange.shade100,
                                child: Text("${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: isGood ? Colors.green : Colors.orange)),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r['studentName'] ?? 'Unknown Student', style: const TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 5),
                                    LinearProgressIndicator(
                                      value: pct / 100,
                                      backgroundColor: Colors.grey.shade200,
                                      color: isGood ? Colors.green : Colors.orange,
                                      minHeight: 8,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                children: [
                                  Text("${r['score']}/${r['totalQuestions']}", style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text("${pct.toStringAsFixed(0)}%", style: TextStyle(fontFamily: "Sans", fontSize: 12, color: isGood ? Colors.green : Colors.orange)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
