import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Classes Collection ---

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
        .orderBy('createdAt', descending: true)
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

  // --- Content Subcollection ---

  Future<bool> addContent({
    required String classId,
    required String title,
    required String type, // 'video' or 'assignment'
    required String url,
  }) async {
    try {
      await _db.collection('classes').doc(classId).collection('content').add({
        'title': title,
        'type': type,
        'url': url,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint("Error adding content: $e");
      return false;
    }
  }

  Stream<QuerySnapshot> getClassContent(String classId) {
    return _db.collection('classes').doc(classId).collection('content')
        .orderBy('createdAt', descending: true)
        .snapshots();
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
      WriteBatch batch = _db.batch();

      DocumentReference studentRef = _db.collection('users').doc(studentId);
      batch.update(studentRef, {
        'linkedParentId': parentId
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

  Future<List<Map<String, dynamic>>> getLinkedChildren(List<dynamic> childIds) async {
    List<Map<String, dynamic>> children = [];
    if (childIds.isEmpty) return children;

    try {
      // Split into batches of 10 if necessary (Firestore limitation for 'whereIn')
      // Assuming for now it's small.
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
}
