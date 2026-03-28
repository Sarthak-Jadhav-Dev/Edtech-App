import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
  }) async {
    try {
      // 1. Create the user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        // 2. Save additional info to Firestore
        // IMPORTANT: Ensure your Firestore Rules are set to "allow read, write: if true;" for testing
        await _db.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'userType': userType,
          'createdAt': Timestamp.now(),
        });

        debugPrint("User data saved to Firestore ✅");
      }

      return user;
    } on FirebaseAuthException catch (e) {
      // Catch specific Firebase Auth errors
      debugPrint("Auth Error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      // Catch Firestore or other errors
      debugPrint("Signup Error: $e");
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint("Login Error: ${e.toString()}");
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<DocumentSnapshot> getUserData() async {
    String uid = _auth.currentUser!.uid;
    return await _db.collection('users').doc(uid).get();
  }
}
