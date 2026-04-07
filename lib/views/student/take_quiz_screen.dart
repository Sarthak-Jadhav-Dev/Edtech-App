import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:kte/views/student/quiz_result_screen.dart';

class TakeQuizScreen extends StatefulWidget {
  final String classId;
  final String quizId;
  final String title;
  final List<dynamic> questions;
  final int timeLimitMinutes;

  const TakeQuizScreen({
    super.key,
    required this.classId,
    required this.quizId,
    required this.title,
    required this.questions,
    required this.timeLimitMinutes,
  });

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  int _currentIndex = 0;
  late List<int> _selectedAnswers;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(widget.questions.length, -1);
    _remainingSeconds = widget.timeLimitMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _submitQuiz();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _timer?.cancel();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final timeTakenSeconds = (widget.timeLimitMinutes * 60) - _remainingSeconds;
    final questions = widget.questions.map((q) => Map<String, dynamic>.from(q as Map)).toList();

    final result = await FirestoreService().submitQuizResult(
      classId: widget.classId,
      quizId: widget.quizId,
      studentId: uid,
      answers: _selectedAnswers,
      questions: questions,
      timeTakenSeconds: timeTakenSeconds,
    );

    if (result != null && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          score: result['score'],
          totalQuestions: result['totalQuestions'],
          percentage: result['percentage'],
          xpEarned: result['xpEarned'],
          isPerfect: result['isPerfect'],
          questions: questions,
          selectedAnswers: _selectedAnswers,
        ),
      ));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit quiz.')));
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex] as Map;
    final options = List<String>.from(question['options'] ?? []);
    final isLast = _currentIndex == widget.questions.length - 1;
    final isTimeLow = _remainingSeconds < 60;

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontFamily: "Poppins", color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isTimeLow ? Colors.red.shade100 : Colors.purple.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, size: 18, color: isTimeLow ? Colors.red : Colors.purple.shade900),
                const SizedBox(width: 5),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: isTimeLow ? Colors.red : Colors.purple.shade900),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress indicator
            Row(
              children: List.generate(widget.questions.length, (i) {
                return Expanded(
                  child: Container(
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _currentIndex ? Colors.purple.shade700 : Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Text("Question ${_currentIndex + 1} of ${widget.questions.length}", style: TextStyle(fontFamily: "Sans", color: Colors.grey.shade600)),
            const SizedBox(height: 20),

            // Question card
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Text(
                question['question'] ?? '',
                style: const TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),

            // Options
            ...List.generate(options.length, (optIdx) {
              final isSelected = _selectedAnswers[_currentIndex] == optIdx;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedAnswers[_currentIndex] = optIdx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purple.shade100 : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? Colors.purple.shade700 : Colors.grey.shade300,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isSelected ? Colors.purple.shade700 : Colors.grey.shade300,
                        child: Text(
                          String.fromCharCode(65 + optIdx),
                          style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          options[optIdx],
                          style: TextStyle(
                            fontFamily: "Sans",
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle, color: Colors.purple),
                    ],
                  ),
                ),
              );
            }),

            const Spacer(),

            // Navigation buttons
            Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentIndex--),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        side: BorderSide(color: Colors.purple.shade700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text("Previous", style: TextStyle(fontFamily: "Sans", color: Colors.purple.shade700)),
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : isLast
                            ? _submitQuiz
                            : () => setState(() => _currentIndex++),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      backgroundColor: isLast ? Colors.green.shade700 : Colors.purple.shade900,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isLast ? "Submit" : "Next", style: const TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
