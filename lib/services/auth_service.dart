import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email & Password Sign Up
  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user profile in Firestore with empty firstName/lastName
      // User will fill these during onboarding
      await _createUserProfile(
        userCredential.user!.uid,
        email,
        '', // Empty - will be filled in onboarding
        '', // Empty - will be filled in onboarding
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email & Password Sign In
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Some auth flows/users may not have a matching Firestore profile yet.
      // Ensure it exists before the UI starts listening to /users/{uid}.
      await ensureUserProfileExists(user: userCredential.user);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Ensures a `/users/{uid}` profile document exists for the given user.
  ///
  /// This prevents the app from crashing/showing `User profile not found` when
  /// the user is authenticated but their Firestore profile hasn't been created
  /// (e.g., older accounts, manual auth creation, or changed auth flows).
  Future<void> ensureUserProfileExists({User? user}) async {
    final u = user ?? _auth.currentUser;
    if (u == null) return;

    final docRef = _firestore.collection('users').doc(u.uid);
    final doc = await docRef.get();

    if (doc.exists) {
      // Don't overwrite user-entered fields; just ensure basic identifiers exist.
      await docRef.set({
        'uid': u.uid,
        'email': u.email ?? '',
      }, SetOptions(merge: true));
      return;
    }

    await docRef.set({
      'uid': u.uid,
      'email': u.email ?? '',
      'firstName': '',
      'lastName': '',
      'phoneNumber': '',
      'bio': '',
      'skills': <String>[],
      'experiences': <Map<String, dynamic>>[],
      'educations': <Map<String, dynamic>>[],
      'interests': <String>[],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  // Check if onboarding is complete for current user
  Future<bool> isOnboardingComplete() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final firstName = data['firstName'] as String? ?? '';
      final lastName = data['lastName'] as String? ?? '';

      return firstName.isNotEmpty && lastName.isNotEmpty;
    } catch (e) {
      throw 'Failed to check onboarding status: $e';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Sign out failed: $e';
    }
  }

  // Create initial user profile in Firestore
  Future<void> _createUserProfile(
    String uid,
    String email,
    String firstName,
    String lastName,
  ) async {
    final userProfile = UserProfile(
      uid: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
    );

    await _firestore.collection('users').doc(uid).set(userProfile.toMap());
  }

  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
