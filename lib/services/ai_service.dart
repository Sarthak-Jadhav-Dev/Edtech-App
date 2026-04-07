import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // TODO: Replace with your actual Gemini API key or use flutter_dotenv
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  static Future<String?> getResponse(String userMessage, List<Content> chatHistory) async {
    try {
      // We use gemini-1.5-flash as it is fast and supports system instructions well
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(
          "You are Buddy, a friendly, enthusiastic, and highly encouraging AI learning buddy for a child aged 6-14. "
          "Keep your answers brief (1-3 sentences), fun, and easy to understand. Always use emojis! "
          "If the child answers a question correctly, learns something new, or asks a super smart question, "
          "you must include the exact text '[REWARD_STAR]' somewhere in your reply to give them a star. "
          "Do not explain what [REWARD_STAR] means, just include it naturally like: 'Great job! [REWARD_STAR]'"
        ),
      );

      final chat = model.startChat(history: chatHistory);
      final response = await chat.sendMessage(Content.text(userMessage));
      return response.text;
    } catch (e) {
      print("Error calling Gemini API: $e");
      return "Oops! I'm resting right now 😴 Let's try again in a bit!";
    }
  }
}
