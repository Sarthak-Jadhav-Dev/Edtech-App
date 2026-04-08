import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../models/chat_message_model.dart';
import '../../../../services/ai_service.dart';
import '../../../../services/chat_firestore_service.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/quick_reply_chips.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ChatFirestoreService _firestoreService = ChatFirestoreService();
  bool _isLoading = false;
  bool _showRewardAnimation = false;

  void _triggerReward() {
    setState(() => _showRewardAnimation = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showRewardAnimation = false);
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userText = text.trim();
    _textController.clear();
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    // Save user message to Firestore
    final defaultId = FirebaseFirestore.instance.collection('_').doc().id;
    final userMessage = ChatMessage(
      id: defaultId,
      text: userText,
      isUser: true,
      timestamp: DateTime.now(),
    );
    await _firestoreService.saveMessage(userMessage);

    // Request AI response
    // Optionally fetch recent messages from stream here to build History
    final aiResponseText = await AiService.getResponse(userText, []);

    if (aiResponseText != null) {
      bool isReward = aiResponseText.contains('[REWARD_STAR]');

      final botMessageId = FirebaseFirestore.instance.collection('_').doc().id;
      final botMessage = ChatMessage(
        id: botMessageId,
        text: aiResponseText,
        isUser: false,
        timestamp: DateTime.now(),
        isReward: isReward,
        rewardAmount: isReward ? 10 : 0,
      );

      await _firestoreService.saveMessage(botMessage);

      if (isReward) {
        _triggerReward();
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Safe fallback icon if lottie network fails
            const Icon(Icons.smart_toy, color: Colors.purple),
            const SizedBox(width: 10),
            const Text(
              "AI Buddy",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.purple),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _firestoreService.getMessagesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.waving_hand, size: 64, color: Colors.purple.shade300)
                                .animate(onPlay: (controller) => controller.repeat())
                                .shakeY(duration: 2.seconds),
                            const SizedBox(height: 16),
                            const Text(
                              "Say hi to your AI Buddy!",
                              style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }

                    final messages = snapshot.data!;
                    return ListView.builder(
                      reverse: true, // List is reversed
                      itemCount: messages.length,
                      padding: const EdgeInsets.all(8.0),
                      itemBuilder: (context, index) {
                        return ChatBubble(message: messages[index]);
                      },
                    );
                  },
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.smart_toy, color: Colors.purple),
                      const SizedBox(width: 10),
                      const Text("Buddy is typing...", style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic))
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 1.seconds),
                    ],
                  ),
                ),
              QuickReplyChips(onSelected: _sendMessage),
              _buildInputArea(),
            ],
          ),
          
          // Reward Overlay
          if (_showRewardAnimation)
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 120, color: Colors.amber)
                        .animate()
                        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), duration: 500.ms, curve: Curves.elasticOut)
                        .then()
                        .shake(duration: 500.ms),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: const Text("+10 XP!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ).animate().slideY(begin: 1.0, end: 0, duration: 300.ms).fadeIn(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, offset: const Offset(0, -2), blurRadius: 4),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: "Ask Buddy something...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 8, offset: const Offset(0,4))],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: () => _sendMessage(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
