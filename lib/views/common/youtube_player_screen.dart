import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kte/models/chat_message_model.dart';
import 'package:kte/services/ai_service.dart';
import 'package:kte/views/student/chatbot/widgets/chat_bubble.dart';
class YouTubePlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;

  const YouTubePlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
  });

  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  YoutubePlayerController? _controller;
  Timer? _progressTimer;
  double _lastSavedPercentage = 0;
  bool _isLoading = true;
  bool _hasResumed = false; // Prevents seeking more than once

  // Chat State
  final List<ChatMessage> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAiTyping = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        final progressSnap =
            await FirestoreService().getVideoProgress(uid, widget.videoId).first;
        if (progressSnap.exists) {
          final data = progressSnap.data() as Map<String, dynamic>;
          final percentage =
              (data['watchedPercentage'] as num?)?.toDouble() ?? 0.0;
          _lastSavedPercentage = percentage;
        }
      } catch (e) {
        debugPrint('Error loading video progress: $e');
      }
    }

    final controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        isLive: false,
        forceHD: false,
        loop: false,
      ),
    );

    // Start periodic progress tracking
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _saveProgress();
    });

    if (!mounted) {
      controller.dispose();
      return;
    }

    setState(() {
      _controller = controller;
      _isLoading = false;
    });
  }

  Future<void> _saveProgress() async {
    final controller = _controller;
    if (controller == null || !controller.value.isReady) return;

    final currentPosition = controller.value.position.inSeconds;
    final totalDuration = controller.value.metaData.duration.inSeconds;

    if (totalDuration > 0) {
      double percentage = (currentPosition / totalDuration) * 100;
      if (percentage > 100) percentage = 100;

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && percentage > _lastSavedPercentage) {
        try {
          await FirestoreService().updateVideoProgress(
            studentId: uid,
            videoId: widget.videoId,
            watchedPercentage: percentage,
          );
          _lastSavedPercentage = percentage;
        } catch (e) {
          debugPrint('Error saving video progress: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _saveProgress(); // Save final progress before leaving
    _controller?.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userText = text.trim();
    _chatController.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: userText,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isAiTyping = true;
    });
    _scrollToBottom();

    // Call AI Service providing the context of the video title
    final responseText = await AiService.getResponse(
      userText,
      [], // Context is mainly provided via title in system instruction here
      contextualVideoTitle: widget.title,
    );

    if (mounted) {
      if (responseText != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: responseText,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
      setState(() {
        _isAiTyping = false;
      });
    }
  }

  Widget _buildChatArea() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Chat Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              border: Border(bottom: BorderSide(color: Colors.purple.shade100)),
            ),
            child: const Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text(
                  "Video AI Buddy",
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        "Want a summary or notes about this video? Just ask!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Newest messages at bottom
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(message: _messages[index]);
                    },
                  ),
          ),
          
          // Typing Indicator
          if (_isAiTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy, color: Colors.purple, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Analyzing video...",
                    style: TextStyle(
                      color: Colors.purple.shade300,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SafeArea(
              top: false, // Ensure we don't double padd if inside safe area
              child: Row(
                children: [
                   Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _chatController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "Ask about this video...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          isDense: true,
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_chatController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    // Show loading state while the controller is being initialised
    if (_isLoading || controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(
              fontFamily: "Poppins",
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.purple),
              SizedBox(height: 16),
              Text(
                'Loading Video...',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: "Sans",
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.purple,
        onReady: () {
          // Resume from last position – only once
          if (!_hasResumed && _lastSavedPercentage > 0 && _lastSavedPercentage < 99) {
            _hasResumed = true;
            final totalDuration = controller.metadata.duration.inSeconds;
            if (totalDuration > 0) {
              final seekTo =
                  (totalDuration * (_lastSavedPercentage / 100)).floor();
              controller.seekTo(Duration(seconds: seekTo));
            }
          }
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(
              widget.title,
              style: const TextStyle(
                fontFamily: "Poppins",
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Column(
            children: [
              player,
              Expanded(child: _buildChatArea()),
            ],
          ),
        );
      },
    );
  }
}
