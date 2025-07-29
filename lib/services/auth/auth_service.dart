// auth_service.dart (Enhanced version)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user info with last login timestamp
      await _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
          'lastLogin': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      throw Exception(message);
    }
  }

  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user info
      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      throw Exception(message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}