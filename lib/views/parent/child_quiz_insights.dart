import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class ChildQuizInsights extends StatelessWidget {
  final String classId;
  final String childId;
  final String childName;

  const ChildQuizInsights({
    super.key,
    required this.classId,
    required this.childId,
    required this.childName,
  });

  Future<Map<String, dynamic>> _getVideoProgressStats() async {
    try {
      // Get all content for this class
      final contentSnap = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('content')
          .where('type', isEqualTo: 'video')
          .get();
      
      final totalVideos = contentSnap.docs.length;
      if (totalVideos == 0) return {'totalVideos': 0, 'watchedVideos': 0, 'percentage': 0.0};

      // Get child's video progress
      int watchedVideos = 0;
      double totalWatchPercentage = 0.0;
      
      for (var contentDoc in contentSnap.docs) {
        final videoId = contentDoc.id;
        final progressDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(childId)
            .collection('progress')
            .doc(videoId)
            .get();
        
        if (progressDoc.exists) {
          final progressData = progressDoc.data() as Map<String, dynamic>;
          final watchedPercentage = (progressData['watchedPercentage'] as num?)?.toDouble() ?? 0.0;
          totalWatchPercentage += watchedPercentage;
          if (watchedPercentage >= 90) {
            watchedVideos++;
          }
        }
      }
      
      final avgPercentage = totalVideos > 0 ? totalWatchPercentage / totalVideos : 0.0;
      
      return {
        'totalVideos': totalVideos,
        'watchedVideos': watchedVideos,
        'percentage': avgPercentage,
      };
    } catch (e) {
      debugPrint('Error fetching video progress: $e');
      return {'totalVideos': 0, 'watchedVideos': 0, 'percentage': 0.0};
    }
  }

  Widget _buildVideoProgressCard(Map<String, dynamic> stats, int totalQuizzes) {
    final totalVideos = stats['totalVideos'] as int;
    final watchedVideos = stats['watchedVideos'] as int;
    final percentage = stats['percentage'] as double;
    
    if (totalVideos == 0 && totalQuizzes == 0) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Learning Progress",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade800,
              ),
            ),
            const SizedBox(height: 16),
            if (totalVideos > 0) ...[
              Row(
                children: [
                  Icon(Icons.play_circle_fill, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Video Progress",
                          style: TextStyle(
                            fontFamily: "Sans",
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.blue.shade100,
                          color: Colors.blue.shade600,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${percentage.toStringAsFixed(0)}% watched • $watchedVideos/$totalVideos completed",
                          style: TextStyle(
                            fontFamily: "Sans",
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(Icons.quiz, color: Colors.orange.shade600),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quizzes Solved",
                      style: TextStyle(
                        fontFamily: "Sans",
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      "$totalQuizzes quiz${totalQuizzes != 1 ? 'zes' : ''} completed",
                      style: TextStyle(
                        fontFamily: "Sans",
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('quiz_results')
          .where('studentId', isEqualTo: childId)
          .orderBy('submittedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data?.docs ?? [];
        final totalQuizzes = results.length;

        if (totalQuizzes == 0) {
          return FutureBuilder<Map<String, dynamic>>(
            future: _getVideoProgressStats(),
            builder: (context, videoStatsSnapshot) {
              if (videoStatsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final videoStats = videoStatsSnapshot.data ?? {'totalVideos': 0, 'watchedVideos': 0, 'percentage': 0.0};
              final hasVideos = (videoStats['totalVideos'] as int) > 0;
              
              if (!hasVideos) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        child: Lottie.asset(
                          'assets/lottie/no_data.json',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.analytics_outlined,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary.withAlpha(100),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No learning data yet.",
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withAlpha(153), fontFamily: "Sans"),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildVideoProgressCard(videoStats, 0),
                ],
              );
            },
          );
        }

        return FutureBuilder<Map<String, dynamic>>(
          future: _getVideoProgressStats(),
          builder: (context, videoStatsSnapshot) {
            final videoStats = videoStatsSnapshot.data ?? {'totalVideos': 0, 'watchedVideos': 0, 'percentage': 0.0};
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length + 1, // +1 for the summary card
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildVideoProgressCard(videoStats, totalQuizzes);
                }
                
                final data = results[index - 1].data() as Map<String, dynamic>;
                final percentage = (data['percentage'] as num?)?.toDouble() ?? 0.0;
                final timeTaken = data['timeTakenSeconds'] as int? ?? 0;
                final insights = data['aiInsights'] as Map<String, dynamic>?;

                final bool isGood = percentage >= 70;
                final Color scoreColor = isGood ? Colors.green : Colors.orange;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: scoreColor.withValues(alpha: 0.1),
                      child: Text(
                        "${percentage.toInt()}%",
                        style: TextStyle(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      "Quiz Attempt",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
                    subtitle: Text(
                      "Time taken: ${(timeTaken / 60).floor()}m ${timeTaken % 60}s",
                      style: const TextStyle(fontSize: 12),
                    ),
                    children: [
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: insights == null
                            ? const Center(
                                child: Text(
                                  "AI Insight is being generated...",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            : _buildInsightsView(insights),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInsightsView(Map<String, dynamic> insights) {
    final parentRemarks = insights['parentRemarks'] ?? "No remark available.";
    final understoodTopics = List<String>.from(
      insights['understoodTopics'] ?? [],
    );
    final focusTopics = List<String>.from(insights['focusTopics'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Buddy Remark
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.smart_toy, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  parentRemarks,
                  style: TextStyle(
                    fontFamily: "Sans",
                    color: Colors.blue.shade900,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (understoodTopics.isNotEmpty) ...[
          const Text(
            "🌟 Strengths",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: understoodTopics
                .map(
                  (t) => Chip(
                    label: Text(
                      t,
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: Colors.green.shade50,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
        ],

        if (focusTopics.isNotEmpty) ...[
          const Text(
            "🎯 Focus Needed",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: focusTopics
                .map(
                  (t) => Chip(
                    label: Text(
                      t,
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: Colors.orange.shade50,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
