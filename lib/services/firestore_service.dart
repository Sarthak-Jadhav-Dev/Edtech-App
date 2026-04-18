import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kte/services/gamification_event_bus.dart';
import 'package:kte/services/ai_quiz_evaluator.dart';
import 'package:kte/services/notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- Content Subcollection ---

  Future<String?> createClass({
    required String name,
    required String description,
    required String subject,
    required String teacherId,
  }) async {
    try {
      final docRef = await _db.collection('classes').add({
        'name': name,
        'description': description,
        'subject': subject,
        'teacherId': teacherId,
        'createdAt': FieldValue.serverTimestamp(),
        'enrolledStudents': [],
        'enrolledParents': [],
      });
      return docRef.id;
    } catch (e) {
      debugPrint("Error creating class: $e");
      return null;
    }
  }

  Stream<QuerySnapshot> getTeacherClasses(String teacherId) {
    return _db.collection('classes')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots();
  }

  Stream<QuerySnapshot> getEnrolledClasses(String userId, String role) {
    final arrayField = role == 'Student' ? 'enrolledStudents' : 'enrolledParents';
    return _db.collection('classes')
        .where(arrayField, arrayContains: userId)
        .snapshots();
  }

  Future<bool> enrollUser(String classId, String userId, String role) async {
    try {
      final arrayField = role == 'Student' ? 'enrolledStudents' : 'enrolledParents';
      await _db.collection('classes').doc(classId).update({
        arrayField: FieldValue.arrayUnion([userId])
      });
      return true;
    } catch (e) {
      debugPrint("Error enrolling user: $e");
      return false;
    }
  }

  Future<DocumentSnapshot> getClassDetails(String classId) async {
    return await _db.collection('classes').doc(classId).get();
  }

  Future<bool> deleteClass(String classId) async {
    try {
      await _db.collection('classes').doc(classId).delete();
      return true;
    } catch (e) {
      debugPrint("Error deleting class: $e");
      return false;
    }
  }

  // --- Content Subcollection ---

  Future<bool> addContent({
    required String classId,
    required String title,
    required String type, // 'video', 'assignment'
    required String url, // Store full URL or Video ID
    String? description,
    String? videoId,
  }) async {
    try {
      await _db.collection('classes').doc(classId).collection('content').add({
        'title': title,
        'type': type,
        'url': url,
        if (videoId != null) 'videoId': videoId,
        if (description != null) 'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint("Error adding content: $e");
      return false;
    }
  }

  Future<bool> updateContent({
    required String classId,
    required String contentId,
    required String title,
    required String type,
    required String url,
    String? description,
    String? videoId,
  }) async {
    try {
      await _db.collection('classes').doc(classId).collection('content').doc(contentId).update({
        'title': title,
        'type': type,
        'url': url,
        if (videoId != null) 'videoId': videoId,
        if (description != null) 'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint("Error updating content: $e");
      return false;
    }
  }

  Stream<QuerySnapshot> getClassContent(String classId) {
    return _db.collection('classes').doc(classId).collection('content')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<bool> deleteContent(String classId, String contentId) async {
    try {
      await _db.collection('classes').doc(classId).collection('content').doc(contentId).delete();
      return true;
    } catch (e) {
      debugPrint("Error deleting content: $e");
      return false;
    }
  }

  // --- Users Collection ---

  Future<DocumentSnapshot?> searchUserByEmail(String email) async {
    try {
      final querySnapshot = await _db.collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      debugPrint("Error searching user: $e");
      return null;
    }
  }

  Future<bool> linkParentToStudent(String studentId, String parentId) async {
    try {
      // Enforce max 2 parents
      final studentDoc = await _db.collection('users').doc(studentId).get();
      if (studentDoc.exists) {
        final data = studentDoc.data() as Map<String, dynamic>;
        final existing = List<String>.from(data['linkedParentIds'] ?? []);
        if (existing.contains(parentId)) return false; // already linked
        if (existing.length >= 2) return false;         // max reached
      }

      WriteBatch batch = _db.batch();

      DocumentReference studentRef = _db.collection('users').doc(studentId);
      batch.update(studentRef, {
        'linkedParentIds': FieldValue.arrayUnion([parentId])
      });

      DocumentReference parentRef = _db.collection('users').doc(parentId);
      batch.update(parentRef, {
        'linkedChildIds': FieldValue.arrayUnion([studentId])
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint("Error linking parent to student: $e");
      return false;
    }
  }

  /// Fetches full parent documents for a student's linked parent IDs.
  Future<List<Map<String, dynamic>>> getLinkedParents(List<dynamic> parentIds) async {
    if (parentIds.isEmpty) return [];
    try {
      final qs = await _db.collection('users')
          .where(FieldPath.documentId, whereIn: parentIds.take(2).toList())
          .get();
      return qs.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint("Error fetching linked parents: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLinkedChildren(List<dynamic> childIds) async {
    List<Map<String, dynamic>> children = [];
    if (childIds.isEmpty) return children;

    try {
      final qs = await _db.collection('users')
          .where(FieldPath.documentId, whereIn: childIds.take(10).toList())
          .get();
      
      for (var doc in qs.docs) {
        var data = doc.data();
        data['uid'] = doc.id;
        children.add(data);
      }
    } catch (e) {
      debugPrint("Error fetching children: $e");
    }
    return children;
  }

  Future<List<Map<String, dynamic>>> getPendingAssignments(String studentId, List<String> classIds) async {
    List<Map<String, dynamic>> allAssignments = [];
    if (classIds.isEmpty) return allAssignments;

    try {
      // Fetch submitted assignment IDs to filter them out
      final submissionsQs = await _db.collection('users').doc(studentId).collection('submissions').get();
      final submittedIds = submissionsQs.docs.map((d) => d.id).toSet();

      for (String classId in classIds) {
        final qs = await _db.collection('classes').doc(classId).collection('content')
            .where('type', isEqualTo: 'assignment')
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();
            
        for (var doc in qs.docs) {
          if (submittedIds.contains(doc.id)) continue;
          
          var data = doc.data();
          data['id'] = doc.id;
          data['classId'] = classId;
          allAssignments.add(data);
        }
      }
      
      allAssignments.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });
    } catch (e) {
      debugPrint("Error fetching assignments: $e");
    }
    return allAssignments;
  }

  Future<List<Map<String, dynamic>>> getTeacherAssignments(List<String> classIds) async {
    List<Map<String, dynamic>> allAssignments = [];
    if (classIds.isEmpty) return allAssignments;

    try {
      for (String classId in classIds) {
        final qs = await _db.collection('classes').doc(classId).collection('content')
            .where('type', isEqualTo: 'assignment')
            .orderBy('createdAt', descending: true)
            .limit(5)
            .get();
            
        for (var doc in qs.docs) {
          var data = doc.data();
          data['id'] = doc.id;
          data['classId'] = classId;
          allAssignments.add(data);
        }
      }
      
      allAssignments.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });
    } catch (e) {
      debugPrint("Error fetching teacher assignments: $e");
    }
    return allAssignments;
  }

  Future<void> submitAssignment({
    required String studentId,
    required String classId,
    required String contentId,
  }) async {
    try {
      await _db.collection('users').doc(studentId).collection('submissions').doc(contentId).set({
        'classId': classId,
        'submittedAt': FieldValue.serverTimestamp(),
        'status': 'completed',
      });
      
      // Award basic XP for finishing an assignment
      await awardXP(studentId, 15);
    } catch (e) {
      debugPrint("Error submitting assignment: $e");
    }
  }

  Future<DocumentSnapshot?> getAssignmentSubmission(String studentId, String contentId) async {
    try {
      final doc = await _db.collection('users').doc(studentId).collection('submissions').doc(contentId).get();
      return doc.exists ? doc : null;
    } catch (e) {
      debugPrint("Error fetching submission: $e");
      return null;
    }
  }

  // --- Student Progress Tracking ---

  // --- YouTube Video Progress Tracking ---

  Future<void> updateVideoProgress({
    required String studentId,
    required String videoId,
    required double watchedPercentage,
  }) async {
    try {
      final completed = watchedPercentage >= 90;
      await _db.collection('users').doc(studentId).collection('progress').doc(videoId).set({
        'watchedPercentage': watchedPercentage,
        'lastWatchedAt': FieldValue.serverTimestamp(),
        'completed': completed,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating video progress: $e");
    }
  }

  Stream<DocumentSnapshot> getVideoProgress(String studentId, String videoId) {
    return _db.collection('users').doc(studentId).collection('progress').doc(videoId).snapshots();
  }

  Future<List<Map<String, dynamic>>> getClassLeaderboard(String classId) async {
    try {
      final classDoc = await getClassDetails(classId);
      if (!classDoc.exists) return [];
      
      final enrolledStudentIds = List<String>.from((classDoc.data() as Map<String, dynamic>)['enrolledStudents'] ?? []);
      if (enrolledStudentIds.isEmpty) return [];

      final userQs = await _db.collection('users')
          .where(FieldPath.documentId, whereIn: enrolledStudentIds.take(10).toList())
          .get();
          
      final List<Map<String, dynamic>> students = [];
      for (var doc in userQs.docs) {
        final data = doc.data();
        data['uid'] = doc.id;
        students.add(data);
      }
      
      students.sort((a, b) => ((b['xp'] ?? 0) as int).compareTo((a['xp'] ?? 0) as int));
      return students;
    } catch (e) {
      debugPrint("Error fetching leaderboard: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getOverallProgressStats(String studentId) async {
    try {
      // 1. Get all enrolled classes
      final enrolledClassesQs = await getEnrolledClasses(studentId, 'Student').first;
      final classDocs = enrolledClassesQs.docs;
      
      if (classDocs.isEmpty) return {'total': 0, 'completed': 0, 'percentage': 0.0};

      int totalContent = 0;
      int completedContent = 0;

      // 2. Get all progress/submissions for filtering
      final videoProgressQs = await _db.collection('users').doc(studentId).collection('progress').get();
      final completedVideos = videoProgressQs.docs.where((d) => (d.data())['completed'] == true).map((d) => d.id).toSet();
      
      final submissionQs = await _db.collection('users').doc(studentId).collection('submissions').get();
      final completedAssignments = submissionQs.docs.where((d) => (d.data())['status'] == 'completed').map((d) => d.id).toSet();

      // 3. Loop through classes and their contents
      for (var classDoc in classDocs) {
        final contentQs = await _db.collection('classes').doc(classDoc.id).collection('content').get();
        totalContent += contentQs.docs.length;
        
        for (var content in contentQs.docs) {
          final data = content.data();
          if (data['type'] == 'video') {
            final videoId = data['videoId'];
            if (videoId != null && completedVideos.contains(videoId)) {
              completedContent++;
            }
          } else if (data['type'] == 'assignment') {
            if (completedAssignments.contains(content.id)) {
              completedContent++;
            }
          }
        }
      }

      final percentage = totalContent == 0 ? 0.0 : (completedContent / totalContent) * 100;

      return {
        'total': totalContent,
        'completed': completedContent,
        'percentage': percentage,
        'classCount': classDocs.length,
      };
    } catch (e) {
      debugPrint("Error fetching overall stats: $e");
      return {'total': 0, 'completed': 0, 'percentage': 0.0};
    }
  }

  Future<List<Map<String, dynamic>>> getClassStudentProgress(String classId) async {
    try {
      final List<Map<String, dynamic>> studentsData = [];
      
      // Get all enrolled students
      final classDoc = await getClassDetails(classId);
      if (!classDoc.exists) return [];
      
      final enrolledStudentIds = List<String>.from((classDoc.data() as Map<String, dynamic>)['enrolledStudents'] ?? []);
      if (enrolledStudentIds.isEmpty) return [];

      // Fetch class content to map properly
      final contentQs = await _db.collection('classes').doc(classId).collection('content').get();

      // Fetch student users
      final userQs = await _db.collection('users').where(FieldPath.documentId, whereIn: enrolledStudentIds.take(10).toList()).get();
      
      for (var doc in userQs.docs) {
        final userData = doc.data();
        final uid = doc.id;

        // Fetch actual progress directly
        final videoProgressQs = await _db.collection('users').doc(uid).collection('progress').get();
        final completedVideos = videoProgressQs.docs.where((d) => (d.data())['completed'] == true).map((d) => d.id).toSet();
        
        final submissionQs = await _db.collection('users').doc(uid).collection('submissions').get();
        final completedAssignments = submissionQs.docs.where((d) => (d.data())['status'] == 'completed').map((d) => d.id).toSet();

        List<String> completedIds = [];
        String lastViewed = "None";
        Timestamp? latestTime;

        for (var content in contentQs.docs) {
          final data = content.data();
          bool isComplete = false;
          
          if (data['type'] == 'video' && data['videoId'] != null) {
            final vId = data['videoId'];
            if (completedVideos.contains(vId)) {
              isComplete = true;
            }
            // Track last watched
            final vDoc = videoProgressQs.docs.where((d) => d.id == vId).firstOrNull;
            if (vDoc != null) {
              final lw = (vDoc.data())['lastWatchedAt'] as Timestamp?;
              if (lw != null && (latestTime == null || lw.compareTo(latestTime) > 0)) {
                latestTime = lw;
                lastViewed = data['title'] ?? 'Video';
              }
            }
          } else if (data['type'] == 'assignment' && completedAssignments.contains(content.id)) {
             isComplete = true;
          }

          if (isComplete) {
            completedIds.add(content.id);
          }
        }

        studentsData.add({
          'uid': uid,
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
          'email': userData['email'],
          'linkedParentIds': userData['linkedParentIds'] ?? [],
          'progress': {
            'completedContentIds': completedIds,
            'lastViewedTitle': lastViewed,
          },
        });
      }
      return studentsData;
    } catch (e) {
      debugPrint("Error fetching class progress: $e");
      return [];
    }
  }

  // --- Quiz System ---

  Future<String?> createQuiz({
    required String classId,
    required String title,
    required String description,
    required int timeLimitMinutes,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final docRef = await _db.collection('classes').doc(classId).collection('quizzes').add({
        'title': title,
        'description': description,
        'timeLimitMinutes': timeLimitMinutes,
        'questions': questions,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint("Error creating quiz: $e");
      return null;
    }
  }

  Stream<QuerySnapshot> getClassQuizzes(String classId) {
    return _db.collection('classes').doc(classId).collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<bool> deleteQuiz(String classId, String quizId) async {
    try {
      await _db.collection('classes').doc(classId).collection('quizzes').doc(quizId).delete();
      return true;
    } catch (e) {
      debugPrint("Error deleting quiz: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> submitQuizResult({
    required String classId,
    required String quizId,
    required String studentId,
    required List<int> answers,
    required List<Map<String, dynamic>> questions,
    required int timeTakenSeconds,
    required String title,
  }) async {
    try {
      int score = 0;
      for (int i = 0; i < questions.length; i++) {
        if (i < answers.length && answers[i] == questions[i]['correctIndex']) {
          score++;
        }
      }
      final percentage = questions.isEmpty ? 0.0 : (score / questions.length) * 100;
      final isPerfect = score == questions.length && questions.isNotEmpty;

      final resultData = {
        'quizId': quizId,
        'studentId': studentId,
        'score': score,
        'totalQuestions': questions.length,
        'percentage': percentage,
        'timeTakenSeconds': timeTakenSeconds,
        'answers': answers,
        'submittedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _db.collection('classes').doc(classId).collection('quiz_results').add(resultData);

      // Trigger AI asynchronously - don't await so the student gets their result instantly
      AiQuizEvaluator.generateInsights(
        questions: questions,
        studentAnswers: answers,
        score: score,
        timeSeconds: timeTakenSeconds,
      ).then((insights) {
        if (insights != null) {
          docRef.update({'aiInsights': insights});
        }
      });

      // Award XP
      int xpEarned = 20; // base XP for taking a quiz
      if (isPerfect) xpEarned += 50; // bonus for perfect score
      
      await awardXP(studentId, xpEarned, isPerfect: isPerfect);

      // Notify Parents
      if (percentage >= 80) {
        NotificationService().notifyParents(
          studentId: studentId,
          title: "Great Quiz Score! 🥳",
          message: "Scored ${percentage.toStringAsFixed(0)}% in '$title'!",
          type: NotificationType.quizScored,
        );
      } else {
         NotificationService().notifyParents(
          studentId: studentId,
          title: "Quiz Completed ✅",
          message: "Finished '$title' quiz.",
          type: NotificationType.quizScored,
        );
      }

      return {
        'score': score,
        'totalQuestions': questions.length,
        'percentage': percentage,
        'xpEarned': xpEarned,
        'isPerfect': isPerfect,
      };
    } catch (e) {
      debugPrint("Error submitting quiz: $e");
      return null;
    }
  }

  Future<QuerySnapshot?> getStudentQuizResult(String classId, String quizId, String studentId) async {
    try {
      return await _db.collection('classes').doc(classId).collection('quiz_results')
          .where('quizId', isEqualTo: quizId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
    } catch (e) {
      debugPrint("Error checking quiz result: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getQuizResultsForQuiz(String classId, String quizId) async {
    try {
      final qs = await _db.collection('classes').doc(classId).collection('quiz_results')
          .where('quizId', isEqualTo: quizId)
          .get();

      List<Map<String, dynamic>> results = [];
      for (var doc in qs.docs) {
        var data = doc.data();
        // Fetch student name
        try {
          final userDoc = await _db.collection('users').doc(data['studentId']).get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            data['studentName'] = "${userData['firstName']} ${userData['lastName']}";
          }
        } catch (_) {}
        results.add(data);
      }
      return results;
    } catch (e) {
      debugPrint("Error fetching quiz results: $e");
      return [];
    }
  }

  // --- Gamification / XP System ---

  Future<void> awardXP(String userId, int xp, {bool isPerfect = false}) async {
    try {
      final userRef = _db.collection('users').doc(userId);
      final userDoc = await userRef.get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentXP = (userData['xp'] as int?) ?? 0;
      final currentQuizzes = (userData['quizzesTaken'] as int?) ?? 0;
      final currentPerfect = (userData['perfectScores'] as int?) ?? 0;
      final currentBadges = List<Map<String, dynamic>>.from(userData['badges'] ?? []);

      final currentLevel = (currentXP / 100).floor() + 1;
      final newXP = currentXP + xp;
      final newLevel = (newXP / 100).floor() + 1; // 100 XP per level
      final newQuizzes = currentQuizzes + 1;
      final newPerfect = isPerfect ? currentPerfect + 1 : currentPerfect;

      // Broadcast simple XP gain
      if (xp > 0) GamificationEventBus.emitReward(RewardEvent(type: RewardType.xpGained, amount: xp));

      if (newLevel > currentLevel) {
        GamificationEventBus.emitReward(RewardEvent(type: RewardType.levelUp, amount: newLevel));
      }

      // Check for new badges
      List<Map<String, dynamic>> newBadges = List.from(currentBadges);
      final badgeNames = newBadges.map((b) => b['name']).toSet();

      if (newQuizzes >= 1 && !badgeNames.contains('Quiz Rookie')) {
        newBadges.add({'name': 'Quiz Rookie', 'icon': 'quiz', 'earnedAt': Timestamp.now()});
        GamificationEventBus.emitReward(RewardEvent(type: RewardType.badgeEarned, title: 'Quiz Rookie'));
        NotificationService().notifyParents(
          studentId: userId,
          title: "New Badge! 🏆",
          message: "Earned the 'Quiz Rookie' badge!",
          type: NotificationType.badgeEarned,
        );
      }
      if (newQuizzes >= 5 && !badgeNames.contains('Quiz Pro')) {
        newBadges.add({'name': 'Quiz Pro', 'icon': 'star', 'earnedAt': Timestamp.now()});
        GamificationEventBus.emitReward(RewardEvent(type: RewardType.badgeEarned, title: 'Quiz Pro'));
        NotificationService().notifyParents(
          studentId: userId,
          title: "New Badge! 🏆",
          message: "Earned the 'Quiz Pro' badge!",
          type: NotificationType.badgeEarned,
        );
      }
      if (newPerfect >= 3 && !badgeNames.contains('Perfectionist')) {
        newBadges.add({'name': 'Perfectionist', 'icon': 'trophy', 'earnedAt': Timestamp.now()});
        GamificationEventBus.emitReward(RewardEvent(type: RewardType.badgeEarned, title: 'Perfectionist'));
        NotificationService().notifyParents(
          studentId: userId,
          title: "New Badge! 🏆",
          message: "Earned the 'Perfectionist' badge!",
          type: NotificationType.badgeEarned,
        );
      }
      if (newXP >= 500 && !badgeNames.contains('XP Hunter')) {
        newBadges.add({'name': 'XP Hunter', 'icon': 'bolt', 'earnedAt': Timestamp.now()});
        GamificationEventBus.emitReward(RewardEvent(type: RewardType.badgeEarned, title: 'XP Hunter'));
      }
      if (newLevel >= 10 && !badgeNames.contains('Veteran Learner')) {
        newBadges.add({'name': 'Veteran Learner', 'icon': 'school', 'earnedAt': Timestamp.now()});
        GamificationEventBus.emitReward(RewardEvent(type: RewardType.badgeEarned, title: 'Veteran Learner'));
      }

      await userRef.update({
        'xp': newXP,
        'level': newLevel,
        'quizzesTaken': newQuizzes,
        'perfectScores': newPerfect,
        'badges': newBadges,
      });
    } catch (e) {
      debugPrint("Error awarding XP: $e");
    }
  }

  Future<void> updateLoginStreak(String userId) async {
    try {
      final userRef = _db.collection('users').doc(userId);
      final userDoc = await userRef.get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final lastLogin = userData['lastLoginDate'] as Timestamp?;
      final currentStreak = (userData['currentStreak'] as int?) ?? 0;

      final now = DateTime.now();
      int newStreak = currentStreak;
      bool streakContinued = false;

      if (lastLogin != null) {
        final lastLoginDate = lastLogin.toDate();
        final difference = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastLoginDate.year, lastLoginDate.month, lastLoginDate.day))
            .inDays;

        if (difference == 1) {
          newStreak++;
          streakContinued = true;
        } else if (difference > 1) {
          newStreak = 1; // Reset
        }
      } else {
        newStreak = 1; 
      }

      await userRef.update({
        'currentStreak': newStreak,
        'lastLoginDate': FieldValue.serverTimestamp(),
      });

      if (streakContinued) {
        // Delay slighty so UI receives it after app start
        Future.delayed(const Duration(seconds: 2), () {
          awardXP(userId, 10);
          GamificationEventBus.emitReward(RewardEvent(type: RewardType.streakContinued, amount: 10));
        });
      }
    } catch (e) {
      debugPrint("Error updating streak: $e");
    }
  }

  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  // --- Doubts System ---

  Future<bool> submitVideoDoubt({
    required String classId,
    required String studentId,
    required String videoId,
    required String videoTitle,
    required String doubtText,
    required String subject,
  }) async {
    try {
      await _db.collection('classes').doc(classId).collection('doubts').add({
        'studentId': studentId,
        'videoId': videoId,
        'videoTitle': videoTitle,
        'doubtText': doubtText,
        'subject': subject,
        'createdAt': FieldValue.serverTimestamp(),
        'isResolved': false,
      });
      return true;
    } catch (e) {
      debugPrint("Error submitting doubt: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getStudentDoubtStats(String studentId, List<String> classIds) async {
    try {
      List<Map<String, dynamic>> allDoubts = [];
      for (String cId in classIds) {
        final qs = await _db.collection('classes').doc(cId).collection('doubts')
            .where('studentId', isEqualTo: studentId)
            .get();
        for (var doc in qs.docs) {
          allDoubts.add(doc.data());
        }
      }
      return allDoubts;
    } catch (e) {
      debugPrint("Error fetching doubt stats: $e");
      return [];
    }
  }
}
