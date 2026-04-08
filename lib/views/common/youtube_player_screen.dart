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
  late YoutubePlayerController _controller;
  Timer? _progressTimer;
  double _lastSavedPercentage = 0;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      // Fetch existing progress
      final progressSnap = await FirestoreService().getVideoProgress(uid, widget.videoId).first;
      if (progressSnap.exists) {
        final data = progressSnap.data() as Map<String, dynamic>;
        final percentage = (data['watchedPercentage'] as num?)?.toDouble() ?? 0.0;
        _lastSavedPercentage = percentage;
        
        // We need duration to calculate startAt position, but we don't have it yet.
        // YouTube player will load and we can seek once ready.
      }
    }

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        isLive: false,
        forceHD: false,
        loop: false,
      ),
    )..addListener(_listener);


    // Start periodic tracking
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _saveProgress();
    });
  }

  void _listener() {
    if (_controller.value.isReady && _lastSavedPercentage > 0 && _lastSavedPercentage < 99) {
       // Perform initial seek if it's the first time being ready
       // This is a bit tricky with this package, usually better to do once.
    }
  }

  Future<void> _saveProgress() async {
    if (!_controller.value.isReady) return;

    final currentPosition = _controller.value.position.inSeconds;
    final totalDuration = _controller.value.metaData.duration.inSeconds;

    if (totalDuration > 0) {
      double percentage = (currentPosition / totalDuration) * 100;
      if (percentage > 100) percentage = 100;

      // Only save if progress has moved significantly or it's a regular interval
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && percentage > _lastSavedPercentage) {
        await FirestoreService().updateVideoProgress(
          studentId: uid,
          videoId: widget.videoId,
          watchedPercentage: percentage,
        );
        _lastSavedPercentage = percentage;
      }
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _saveProgress();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.purple,
        onReady: () {
          // Resume logic
          if (_lastSavedPercentage > 0) {
            final totalDuration = _controller.metadata.duration.inSeconds;
            if (totalDuration > 0) {
              final seekTo = (totalDuration * (_lastSavedPercentage / 100)).floor();
              _controller.seekTo(Duration(seconds: seekTo));
            }
          }
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(widget.title, style: const TextStyle(fontFamily: "Poppins", color: Colors.white, fontSize: 16)),
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(child: player),
        );
      },
    );
  }
}
