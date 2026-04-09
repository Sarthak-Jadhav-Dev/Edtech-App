import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ─── Email & Password Authentication ──────────────────────────────────────

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
  }) async {
    try {
      // 1. Create account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;

      // 2. Save to Firestore
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': email.trim(),
          'userType': userType,
          'createdAt': Timestamp.now(),
          'photoUrl': null,
        });
        debugPrint('User data saved to Firestore ✅');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Auth Error: ${e.code} - ${e.message}');
      String message = 'Registration Failed';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already in use.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      }
      throw Exception(message);
    } catch (e) {
      debugPrint('Signup Error: $e');
      throw Exception('An unknown error occurred.');
    }
  }

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login Error: ${e.code} - ${e.message}');
      String message = 'Login Failed';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      }
      
      throw Exception(message);
    } catch (e) {
      debugPrint('Login Error: $e');
      throw Exception('An unknown error occurred.');
    }
  }


  // ─── Google Sign-In ───────────────────────────────────────────────────────
  //
  // Returns a Map with:
  //   'user'      → FirebaseUser
  //   'isNewUser' → bool  (true = first-time Google user, needs role selection)

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Trigger the Google Auth flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) return null;

      // Check if the Firestore document already exists
      final docSnapshot = await _db.collection('users').doc(user.uid).get();
      final isNewUser = !docSnapshot.exists;

      if (isNewUser) {
        // Create a skeleton document. userType will be filled after role dialog.
        await _db.collection('users').doc(user.uid).set({
          'firstName': user.displayName?.split(' ').first ?? '',
          'lastName': (user.displayName?.split(' ').length ?? 0) > 1
              ? user.displayName!.split(' ').sublist(1).join(' ')
              : '',
          'email': user.email ?? '',
          'userType': null, // will be set after user picks a role
          'photoUrl': user.photoURL,
          'createdAt': Timestamp.now(),
        });
        debugPrint('New Google user document created ✅');
      }

      return {'user': user, 'isNewUser': isNewUser};
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Auth Error: ${e.code} - ${e.message}');
      throw Exception(e.message ?? 'Google Sign-In Failed');
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      throw Exception('Google Sign-In Failed. Please try again.');
    }
  }

  /// Call this after the user picks a role in the role-selection dialog.
  Future<void> setUserRole(String uid, String userType) async {
    await _db.collection('users').doc(uid).update({'userType': userType});
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut(); // also clears Google session
    } catch (e) {
      debugPrint("Google Sign Out Error (Can be ignored if dummy account): $e");
    }
    await _auth.signOut();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("Error sending reset email: $e");
      rethrow;
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name);
    } catch (e) {
      debugPrint("Error updating display name: $e");
    }
  }

  Future<void> deleteAccount() async {
    try {
      // Note: Re-authentication might be required by Firebase for this action in production
      await _auth.currentUser?.delete();
    } catch (e) {
      debugPrint("Error deleting account: $e");
      rethrow;
    }
  }

  Future<DocumentSnapshot> getUserData() async {
    final uid = _auth.currentUser!.uid;
    return await _db.collection('users').doc(uid).get();
  }

  User? get currentUser => _auth.currentUser;
}
