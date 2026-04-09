import 'package:flutter/material.dart';
import 'package:kte/services/firestore_service.dart';

class CreateQuizScreen extends StatefulWidget {
  final String classId;

  const CreateQuizScreen({super.key, required this.classId});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _timeLimit = 10;
  bool _isLoading = false;

  final List<_QuestionData> _questions = [_QuestionData()];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (var q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_QuestionData());
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length <= 1) return;
    setState(() {
      _questions[index].dispose();
      _questions.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz title is required')));
      return;
    }

    // Validate all questions
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.questionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Question ${i + 1} text is empty')));
        return;
      }
      for (int j = 0; j < 4; j++) {
        if (q.optionControllers[j].text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Question ${i + 1}, Option ${j + 1} is empty')));
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    final questions = _questions.map((q) => {
      'question': q.questionController.text.trim(),
      'options': q.optionControllers.map((c) => c.text.trim()).toList(),
      'correctIndex': q.correctIndex,
    }).toList();

    final id = await FirestoreService().createQuiz(
      classId: widget.classId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      timeLimitMinutes: _timeLimit,
      questions: questions,
    );

    setState(() => _isLoading = false);

    if (id != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz created successfully!')));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create quiz.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("Create Quiz", style: TextStyle(fontFamily: "Poppins", color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuestion,
        backgroundColor: Colors.purple.shade900,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quiz Info Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Quiz Title",
                      prefixIcon: Icon(Icons.quiz, color: Colors.purple.shade400),
                      filled: true,
                      fillColor: Colors.purple.shade50.withValues(alpha: 0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: "Description (Optional)",
                      prefixIcon: Icon(Icons.description, color: Colors.purple.shade400),
                      filled: true,
                      fillColor: Colors.purple.shade50.withValues(alpha: 0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.purple.shade400),
                      const SizedBox(width: 10),
                      const Text("Time Limit:", style: TextStyle(fontFamily: "Sans", fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      DropdownButton<int>(
                        value: _timeLimit,
                        items: [5, 10, 15, 20, 30].map((v) => DropdownMenuItem(value: v, child: Text("$v min"))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _timeLimit = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text("Questions (${_questions.length})", style: const TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Question Cards
            ...List.generate(_questions.length, (index) {
              return _buildQuestionCard(index);
            }),

            const SizedBox(height: 20),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveQuiz,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.purple.shade900,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                    ),
                    child: const Text("Publish Quiz", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 18)),
                  ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final q = _questions[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple.shade200,
                radius: 16,
                child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text("Question", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold))),
              if (_questions.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  onPressed: () => _removeQuestion(index),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: q.questionController,
            decoration: InputDecoration(
              hintText: "Enter question...",
              filled: true,
              fillColor: Colors.purple.shade50.withValues(alpha: 0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 15),
          ...List.generate(4, (optIdx) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // ignore: deprecated_member_use
                  Radio<int>(
                    value: optIdx,
                    // ignore: deprecated_member_use
                    groupValue: q.correctIndex,
                    activeColor: Colors.green,
                    // ignore: deprecated_member_use
                    onChanged: (val) {
                      setState(() => q.correctIndex = val!);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: q.optionControllers[optIdx],
                      decoration: InputDecoration(
                        hintText: "Option ${optIdx + 1}",
                        filled: true,
                        fillColor: q.correctIndex == optIdx ? Colors.green.shade50 : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Text("Tap radio to mark correct answer", style: TextStyle(fontFamily: "Sans", fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _QuestionData {
  final TextEditingController questionController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(4, (_) => TextEditingController());
  int correctIndex = 0;

  void dispose() {
    questionController.dispose();
    for (var c in optionControllers) {
      c.dispose();
    }
  }
}
