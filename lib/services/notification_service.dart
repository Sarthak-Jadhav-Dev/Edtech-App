import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum NotificationType {
  quizScored,
  badgeEarned,
  courseCompleted,
  loginStreak
}

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendNotification({
    required String recipientId,
    required String studentId,
    required String studentName,
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    try {
      await _db.collection('notifications').add({
        'recipientId': recipientId,
        'studentId': studentId,
        'studentName': studentName,
        'title': title,
        'message': message,
        'type': type.toString().split('.').last,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      debugPrint("Error sending notification: $e");
    }
  }

  // Helper to notify all parents of a student
  Future<void> notifyParents({
    required String studentId,
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    try {
      final studentDoc = await _db.collection('users').doc(studentId).get();
      if (!studentDoc.exists) return;

      final data = studentDoc.data() as Map<String, dynamic>;
      final parentIds = List<String>.from(data['linkedParentIds'] ?? []);
      final studentName = "${data['firstName']} ${data['lastName']}";

      for (String parentId in parentIds) {
        await sendNotification(
          recipientId: parentId,
          studentId: studentId,
          studentName: studentName,
          title: title,
          message: message,
          type: type,
        );
      }
    } catch (e) {
      debugPrint("Error notifying parents: $e");
    }
  }

  Stream<QuerySnapshot> getNotifications(String parentId) {
    return _db.collection('notifications')
        .where('recipientId', isEqualTo: parentId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String parentId) async {
    final docs = await _db.collection('notifications')
        .where('recipientId', isEqualTo: parentId)
        .where('isRead', isEqualTo: false)
        .get();
    
    WriteBatch batch = _db.batch();
    for (var doc in docs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
