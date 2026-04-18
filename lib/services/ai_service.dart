import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AiService {
  static const String _apiKey = '[GCP_API_KEY]';

  static Future<String?> getResponse(String userMessage,List<Content> chatHistory,{String? contextualVideoTitle,}) async {
    try {
      String extraContext = contextualVideoTitle != null? "\n\nThe student is currently watching an educational video titled: '$contextualVideoTitle'. Please answer their questions referring to this video, summarize it if asked, and help them take notes on it. Keep your language encouraging." : "";

      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(
          "You are Buddy, a friendly, enthusiastic, and highly encouraging AI learning buddy for a child aged 6-14. "
          "Keep your answers brief (1-3 sentences), fun, and easy to understand. Always use emojis! "
          "If the child answers a question correctly, learns something new, or asks a super smart question, "
          "you must include the exact text '[REWARD_STAR]' somewhere in your reply to give them a star. "
          "Do not explain what [REWARD_STAR] means, just include it naturally like: 'Great job! [REWARD_STAR]'$extraContext",
        ),
      );
      final chat = model.startChat(history: chatHistory);
      final response = await chat.sendMessage(Content.text(userMessage));
      return response.text;
    } catch (e) {
      debugPrint("Error calling Gemini API: $e");
      return "Oops! I'm resting right now 😴 Let's try again in a bit!";
    }
  }

  static Future<String?> generateHolisticReport({
    required String studentName,
    required int totalItems,
    required int completedItems,
    required int totalQuizzes,
    required double avgQuizScore,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyAgAPcL2ITodk_UnfL4-ezpAi1mYURBl3o', // API Key
        systemInstruction: Content.system(
          "You are an expert educational AI counselor. Your goal is to write a warm, encouraging, but highly insightful 2-paragraph personalized report for a student's parent and teacher. "
          "You will receive the student's metrics. Note any areas of strength or areas to focus on. Keep it professional and empathetic. Do not use complex markdown, just basic text structure."
        ),
      );

      final prompt = "Generate a personalized holistic report for student: $studentName.\n"
          "Stats:\n- Total Course Items: $totalItems\n- Completed Items: $completedItems\n"
          "- Quizzes Taken: $totalQuizzes\n- Average Quiz Score: ${avgQuizScore.toStringAsFixed(1)}%\n\n"
          "Write the report now.";

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      debugPrint("Error generating AI holistic report: $e");
      return "Unable to generate the personalized report at this time. Please check your connection and try again later.";
    }
  }
}
