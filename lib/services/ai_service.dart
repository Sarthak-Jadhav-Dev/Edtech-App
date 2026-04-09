import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const String _apiKey = '[GCP_API_KEY]';

  static Future<String?> getResponse(
    String userMessage,
    List<Content> chatHistory, {
    String? contextualVideoTitle,
  }) async {
    try {
      String extraContext = contextualVideoTitle != null
          ? "\n\nThe student is currently watching an educational video titled: '$contextualVideoTitle'. Please answer their questions referring to this video, summarize it if asked, and help them take notes on it. Keep your language encouraging."
          : "";

      // We use gemini-2.0-flash as it is fast and supports system instructions well
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
}
