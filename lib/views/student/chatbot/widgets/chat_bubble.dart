import 'package:flutter/material.dart';
import '../../../../models/chat_message_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.isUser;
    
    // We strip out the hidden marker before displaying
    final displayText = message.text.replaceAll('[REWARD_STAR]', '').trim();
    if (displayText.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.white : Colors.blue.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Text(
          displayText,
          style: TextStyle(
            fontFamily: 'Nunito', // Or fallback to default sans
            fontSize: 16,
            color: isMe ? Colors.black87 : Colors.blue.shade900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ).animate().slideY(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOut).fadeIn(),
    );
  }
}
