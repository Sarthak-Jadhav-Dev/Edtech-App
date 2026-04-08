import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiQuizEvaluator {
  static const String _apiKey = 'AIzaSyAgAPcL2ITodk_UnfL4-ezpAi1mYURBl3o';
  
  static Future<Map<String, dynamic>?> generateInsights({
    required List<Map<String, dynamic>> questions,
    required List<int> studentAnswers,
    required int score,
    required int timeSeconds,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(
          "You are an expert tutor creating a specialized performance report based on a student's quiz attempt. "
          "You will receive the quiz data. Provide your output STRICTLY as a valid raw JSON object string. Do not wrap it in ```json. "
          "The JSON must have exactly these keys: "
          "\"coveredTopics\": [list of short topic strings], "
          "\"understoodTopics\": [list of short topic strings], "
          "\"focusTopics\": [list of short topic strings], "
          "\"parentRemarks\": \"a warm supportive remark for parents\", "
          "\"teacherRemarks\": \"an analytical remark for the teacher\""
        ),
      );

      final promptText = """
Analyze this quiz attempt:
Score: $score out of ${questions.length}
Time elapsed: $timeSeconds seconds

Questions and Answers context:
${_formatQuizData(questions, studentAnswers)}
""";

      final content = [Content.text(promptText)];
      final response = await model.generateContent(content);
      
      final String? responseText = response.text;
      if (responseText == null) return null;
      
      String jsonString = responseText.trim();
      if (jsonString.startsWith("```json")) {
        jsonString = jsonString.replaceAll("```json", "");
        jsonString = jsonString.replaceAll("```", "");
        jsonString = jsonString.trim();
      } else if (jsonString.startsWith("```")) {
        jsonString = jsonString.replaceAll("```", "");
        jsonString = jsonString.trim();
      }

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Error generating AI insights: $e");
      return null; 
    }
  }

  static String _formatQuizData(List<Map<String, dynamic>> questions, List<int> answers) {
    String result = "";
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final opts = q['options'] as List<dynamic>? ?? [];
      final correctIdx = q['correctIndex'] as int? ?? -1;
      final studentIdx = answers.length > i ? answers[i] : -1;
      
      final correctAns = correctIdx >= 0 && correctIdx < opts.length ? opts[correctIdx] : "Unknown";
      final studentAns = studentIdx >= 0 && studentIdx < opts.length ? opts[studentIdx] : "Unanswered";
      final isCorrect = correctIdx == studentIdx;

      result += "Q${i+1}: ${q['question']}\n";
      result += "Student Answer: $studentAns (${isCorrect ? "Correct" : "Incorrect"})\n";
      if (!isCorrect) result += "Correct Answer: $correctAns\n";
      result += "\n";
    }
    return result;
  }
}
