import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kte/services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationCenter extends StatelessWidget {
  const NotificationCenter({super.key});

  IconData _getIcon(String type) {
    switch (type) {
      case 'quizScored': return Icons.quiz;
      case 'badgeEarned': return Icons.emoji_events;
      case 'courseCompleted': return Icons.auto_stories;
      case 'loginStreak': return Icons.local_fire_department;
      default: return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'quizScored': return Colors.deepOrange;
      case 'badgeEarned': return Colors.amber.shade700;
      case 'courseCompleted': return Colors.green;
      case 'loginStreak': return Colors.orange;
      default: return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("Child Achievements", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.purple),
            onPressed: () => NotificationService().markAllAsRead(uid),
            tooltip: "Mark all as read",
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: NotificationService().getNotifications(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.notifications_none, size: 80, color: Colors.purple.withValues(alpha: 0.2)),
                   const SizedBox(height: 20),
                   const Text("No notifications yet", style: TextStyle(fontFamily: "Sans", color: Colors.grey, fontSize: 16)),
                   const Padding(
                     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                     child: Text("You'll see your child's milestones and activity updates here!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
                   )
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final nId = docs[index].id;
              final type = data['type'] ?? 'default';
              final isRead = data['isRead'] ?? false;
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

              return Card(
                elevation: isRead ? 0 : 4,
                margin: const EdgeInsets.only(bottom: 12),
                color: isRead ? Colors.white.withValues(alpha: 0.8) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: InkWell(
                  onTap: () => NotificationService().markAsRead(nId),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: _getColor(type).withValues(alpha: 0.1),
                          child: Icon(_getIcon(type), color: _getColor(type), size: 20),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    data['studentName']?.toString().toUpperCase() ?? "CHILD UPDATE",
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple.shade300, letterSpacing: 1),
                                  ),
                                  if (timestamp != null)
                                    Text(
                                      DateFormat('MMM d, h:mm a').format(timestamp),
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['title'] ?? "Notification",
                                style: TextStyle(fontSize: 16, fontWeight: isRead ? FontWeight.normal : FontWeight.bold, fontFamily: "Poppins"),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                data['message'] ?? "",
                                style: const TextStyle(fontSize: 14, color: Colors.black54, fontFamily: "Sans"),
                              ),
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                          )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
