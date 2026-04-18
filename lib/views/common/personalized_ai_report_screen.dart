import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:kte/services/ai_service.dart';
import 'package:kte/services/firestore_service.dart';

class PersonalizedAiReportScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String classId;

  const PersonalizedAiReportScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.classId,
  });

  @override
  State<PersonalizedAiReportScreen> createState() => _PersonalizedAiReportScreenState();
}

class _PersonalizedAiReportScreenState extends State<PersonalizedAiReportScreen> {
  bool _isLoading = true;
  String? _generatedReport;

  @override
  void initState() {
    super.initState();
    _fetchStatsAndGenerateReport();
  }

  Future<void> _fetchStatsAndGenerateReport() async {
    try {
      // Fetch classes this student is in or just use this classId
      // For holistic, we'll try to get all overall data up to what's easily queried.
      final overallStats = await FirestoreService().getOverallProgressStats(widget.studentId);
      
      final totalContent = overallStats['total'] as int? ?? 0;
      final completedContent = overallStats['completed'] as int? ?? 0;

      // Quizzes
      final quizQs = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('quiz_results')
          .where('studentId', isEqualTo: widget.studentId)
          .get();

      int totalQuizzes = quizQs.docs.length;
      double totalScorePercentage = 0;
      for (var doc in quizQs.docs) {
        totalScorePercentage += (doc.data()['percentage'] as num?)?.toDouble() ?? 0.0;
      }
      double avgQuizScore = totalQuizzes == 0 ? 0.0 : (totalScorePercentage / totalQuizzes);

      final report = await AiService.generateHolisticReport(
        studentName: widget.studentName,
        totalItems: totalContent,
        completedItems: completedContent,
        totalQuizzes: totalQuizzes,
        avgQuizScore: avgQuizScore,
      );

      if (mounted) {
        setState(() {
          _generatedReport = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _generatedReport = "An error occurred while generating the report. Please try again.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("AI Personalized Report", style: TextStyle(fontFamily: "Poppins", color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.purple),
                  const SizedBox(height: 20),
                  Text("Analyzing learning patterns...", style: TextStyle(fontFamily: "Sans", color: Colors.purple.shade700)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade50, Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          Icon(Icons.auto_awesome, size: 50, color: Colors.orange.shade400),
                          const SizedBox(height: 15),
                          Text(
                            "${widget.studentName}'s Holistic Report",
                            style: const TextStyle(fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 20),
                          // Output Markdown roughly or Text
                          Text(
                            _generatedReport ?? "No report generated.",
                            style: TextStyle(fontFamily: "Sans", fontSize: 16, color: Colors.grey.shade800, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
