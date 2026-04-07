import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../services/gamification_event_bus.dart';

class GlobalRewardOverlay extends StatefulWidget {
  final Widget child;

  const GlobalRewardOverlay({Key? key, required this.child}) : super(key: key);

  @override
  State<GlobalRewardOverlay> createState() => _GlobalRewardOverlayState();
}

class _GlobalRewardOverlayState extends State<GlobalRewardOverlay> {
  late StreamSubscription _subscription;
  List<RewardEvent> _activeToasts = [];
  bool _showLevelUp = false;

  final List<String> _motivationalPhrases = [
    "Awesome work! 🚀",
    "You're on fire! 🔥",
    "Brain power +10! 🧠",
    "Super smart! ⭐",
    "Keep it up! 🎯"
  ];

  @override
  void initState() {
    super.initState();
    _subscription = GamificationEventBus.onReward.listen((event) {
      if (event.type == RewardType.levelUp) {
        _triggerLevelUp();
      } else {
        _addToast(event);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _triggerLevelUp() {
    setState(() => _showLevelUp = true);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showLevelUp = false);
    });
  }

  void _addToast(RewardEvent event) {
    if (!mounted) return;
    setState(() {
      _activeToasts.add(event);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _activeToasts.isNotEmpty) {
        setState(() {
          _activeToasts.removeAt(0); // Remove oldest
        });
      }
    });
  }

  String _getRandomPhrase() {
    final rand = Random();
    return _motivationalPhrases[rand.nextInt(_motivationalPhrases.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        // Active Toasts
        if (_activeToasts.isNotEmpty)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: _activeToasts.map((event) {
                return _buildToast(event).animate().slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOutBack).fadeIn();
              }).toList(),
            ),
          ),

        // Level Up Full Screen Overlay
        if (_showLevelUp)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.military_tech, size: 150, color: Colors.amber)
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .scaleXY(begin: 0.8, end: 1.2, duration: 800.ms)
                        .shimmer(duration: 1.seconds),
                    const SizedBox(height: 20),
                    const Text(
                      "LEVEL UP! 🎉",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.orange, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                    ).animate().slideY(begin: 1, end: 0).fadeIn(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToast(RewardEvent event) {
    IconData iconData = Icons.star;
    Color color = Colors.amber;
    String text = "+${event.amount} XP! ${_getRandomPhrase()}";

    if (event.type == RewardType.badgeEarned) {
      iconData = Icons.military_tech;
      color = Colors.purpleAccent;
      text = "New Badge: ${event.title}!";
    } else if (event.type == RewardType.streakContinued) {
      iconData = Icons.local_fire_department;
      color = Colors.deepOrange;
      text = "Streak continued! +${event.amount} XP";
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: color, size: 28),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
