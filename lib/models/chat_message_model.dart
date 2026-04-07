class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isReward;
  final int rewardAmount;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isReward = false,
    this.rewardAmount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isReward': isReward,
      'rewardAmount': rewardAmount,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessage(
      id: docId,
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isReward: map['isReward'] ?? false,
      rewardAmount: map['rewardAmount'] ?? 0,
    );
  }
}
