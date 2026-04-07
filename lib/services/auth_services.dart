import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ─── Dummy Email (Phone -> Email mapped) Login ──────────────────────────

  Future<User?> loginWithPhone(String phone, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: '$phone@kte.app',
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Login Error: ${e.toString()}');
      return null;
    }
  }

  // ─── Phone OTP & Dummy Email Registration ───────────────────────────────

  Future<void> sendOTP({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('Verification Failed: ${e.code} - ${e.message}');
        String errorMessage = e.message ?? 'Verification failed';
        if (e.code == 'invalid-phone-number') {
          errorMessage = 'The provided phone number is not valid.';
        }
        onError(errorMessage);
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<User?> verifyOTPAndSignUp({
    required String verificationId,
    required String smsCode,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
  }) async {
    try {
      // 1. Verify OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final phoneUser = await _auth.signInWithCredential(credential);

      // 2. Delete temporary phone user to avoid auth conflicts
      await phoneUser.user?.delete();

      // 3. Create dummy email account for password logins
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: '$phone@kte.app',
        password: password,
      );

      final user = userCredential.user;

      // 4. Save to Firestore
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': '$phone@kte.app',
          'phoneNumber': phone,
          'userType': userType,
          'createdAt': Timestamp.now(),
          'photoUrl': null,
        });
        debugPrint('User data saved to Firestore ✅');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Auth Error: ${e.code} - ${e.message}');
      throw Exception(e.message ?? 'Registration Failed');
    } catch (e) {
      debugPrint('Signup Error: $e');
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
    await _googleSignIn.signOut(); // also clears Google session
    await _auth.signOut();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<DocumentSnapshot> getUserData() async {
    final uid = _auth.currentUser!.uid;
    return await _db.collection('users').doc(uid).get();
  }

  User? get currentUser => _auth.currentUser;
}
