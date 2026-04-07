import 'dart:async';

enum RewardType { xpGained, badgeEarned, levelUp, streakContinued }

class RewardEvent {
  final RewardType type;
  final int amount;
  final String title;

  RewardEvent({required this.type, this.amount = 0, this.title = ''});
}

class GamificationEventBus {
  static final StreamController<RewardEvent> _controller = StreamController<RewardEvent>.broadcast();
  static Stream<RewardEvent> get onReward => _controller.stream;
  static void emitReward(RewardEvent event) {
    _controller.add(event);
  }
  static void dispose() {
    _controller.close();
  }
}
