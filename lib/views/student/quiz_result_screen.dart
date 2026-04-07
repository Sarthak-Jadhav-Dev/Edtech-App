import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final double percentage;
  final int xpEarned;
  final bool isPerfect;
  final List<Map<String, dynamic>> questions;
  final List<int> selectedAnswers;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.xpEarned,
    required this.isPerfect,
    required this.questions,
    required this.selectedAnswers,
  });

  IconData _getBadgeIcon() {
    if (isPerfect) return Icons.emoji_events;
    if (percentage >= 70) return Icons.thumb_up;
    return Icons.sentiment_neutral;
  }

  Color _getScoreColor() {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getMessage() {
    if (isPerfect) return "🎉 Perfect Score!";
    if (percentage >= 80) return "🌟 Great Job!";
    if (percentage >= 50) return "👍 Good Effort!";
    return "💪 Keep Trying!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("Quiz Result", style: TextStyle(fontFamily: "Poppins", color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Celebration Animation
            if (isPerfect || percentage >= 70)
              SizedBox(
                height: 150,
                child: Lottie.network(
                  'https://assets2.lottiefiles.com/packages/lf20_touohxv0.json',
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(_getBadgeIcon(), size: 80, color: _getScoreColor()),
                ),
              )
            else
              Icon(_getBadgeIcon(), size: 80, color: _getScoreColor()),

            const SizedBox(height: 15),
            Text(_getMessage(), style: const TextStyle(fontFamily: "Poppins", fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Score Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade900, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Text("$score / $totalQuestions", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "Poppins")),
                    const SizedBox(height: 5),
                    Text("${percentage.toStringAsFixed(0)}% Correct", style: const TextStyle(color: Colors.white70, fontFamily: "Sans", fontSize: 16)),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: Colors.white, size: 20),
                          const SizedBox(width: 5),
                          Text("+$xpEarned XP Earned!", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Answer Review", style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            // Answer Review
            ...List.generate(questions.length, (i) {
              final q = questions[i];
              final options = List<String>.from(q['options'] ?? []);
              final correctIdx = q['correctIndex'] as int;
              final selectedIdx = i < selectedAnswers.length ? selectedAnswers[i] : -1;
              final isCorrect = selectedIdx == correctIdx;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: isCorrect ? Colors.green : Colors.red,
                            child: Icon(isCorrect ? Icons.check : Icons.close, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text("Q${i + 1}: ${q['question']}", style: const TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (selectedIdx >= 0 && selectedIdx < options.length)
                        Text("Your answer: ${options[selectedIdx]}", style: TextStyle(fontFamily: "Sans", color: isCorrect ? Colors.green : Colors.red)),
                      if (selectedIdx < 0)
                        const Text("Not answered", style: TextStyle(fontFamily: "Sans", color: Colors.orange)),
                      if (!isCorrect && correctIdx < options.length)
                        Text("Correct: ${options[correctIdx]}", style: const TextStyle(fontFamily: "Sans", color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.purple.shade900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Back to Course", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 16)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
