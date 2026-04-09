import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    super.dispose();
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
          body: Center(child: player),
        );
      },
    );
  }
}
