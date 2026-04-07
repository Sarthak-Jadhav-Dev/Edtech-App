import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message_model.dart';

class ChatFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Using a single continuous session for simplicity. Can be extended to daily or topic-based sessions.
  final String currentSessionId = 'main_buddy_chat';

  Stream<List<ChatMessage>> getMessagesStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .doc(currentSessionId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // Newest first
        .limit(50) // Limit read costs
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> saveMessage(ChatMessage message) async {
    final uid = currentUserId;
    if (uid == null) return;

    // Save the message
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .doc(currentSessionId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());

    // Update session metadata
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .doc(currentSessionId)
        .set({
      'lastUpdated': FieldValue.serverTimestamp(),
      'isActive': true,
    }, SetOptions(merge: true));
    
    // If it's a reward, optionally add XP to the user's main document
    if (message.isReward) {
      await _firestore.collection('users').doc(uid).update({
        'xp': FieldValue.increment(message.rewardAmount),
      }).catchError((e) {
         // Field might not exist yet, set it instead
         _firestore.collection('users').doc(uid).set({'xp': message.rewardAmount}, SetOptions(merge: true));
      });
    }
  }
}
