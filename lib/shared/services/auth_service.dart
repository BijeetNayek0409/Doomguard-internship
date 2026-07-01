// lib/shared/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;

  Future<AppUser?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) return null;

    return _upsertUserDoc(user);
  }

  Future<AppUser> _upsertUserDoc(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();
    final now = Timestamp.now(); // ✅ Timestamp, not DateTime

    if (snapshot.exists) {
      await docRef.update({'lastLogin': now}); // ✅ Timestamp written correctly
      final data = snapshot.data()!;
      return AppUser(
        uid: user.uid,
        name: data['name'] as String? ?? user.displayName ?? 'DoomGuard User',
        email: data['email'] as String? ?? user.email ?? '',
        photoUrl: data['photoUrl'] as String? ?? user.photoURL ?? '',
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        lastLogin: now.toDate(),
        surveyCompleted: data['surveyCompleted'] as bool? ?? false,
        isChild: data['isChild'] as bool? ?? false,
        guardianEmail: data['guardianEmail'] as String?,
      );
    } else {
      final newUser = AppUser(
        uid: user.uid,
        name: user.displayName ?? 'DoomGuard User',
        email: user.email ?? '',
        photoUrl: user.photoURL ?? '',
        createdAt: now.toDate(),
        lastLogin: now.toDate(),
        surveyCompleted: false,
      );
      await docRef.set(newUser.toMap()); // toMap() already uses Timestamp.fromDate()
      return newUser;
    }
  }

  Future<AppUser> getUserFromFirestore(String uid) async {
    debugPrint('🔍 Fetching Firestore doc for UID: $uid');
    final doc = await _firestore.collection('users').doc(uid).get();
    debugPrint('📄 Doc exists: ${doc.exists}');

    if (!doc.exists) throw Exception('User doc not found for UID: $uid');

    final data = doc.data()!;
    debugPrint('✅ surveyCompleted from Firestore: ${data['surveyCompleted']}');

    return AppUser(
      uid: uid,
      name: data['name'] as String? ?? 'DoomGuard User',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: (data['lastLogin'] as Timestamp).toDate(),
      surveyCompleted: data['surveyCompleted'] as bool? ?? false,
      isChild: data['isChild'] as bool? ?? false,
      guardianEmail: data['guardianEmail'] as String?,
    );
  }

  /// Saves the survey. `isChild` and `guardianEmail` are pulled out and
  /// written top-level on the user doc (not nested under `survey`) so
  /// backend scripts can query them directly, e.g.:
  ///   users.where('isChild', '==', True).where('guardianEmail', '!=', None)
  /// Everything else stays nested under `survey`, matching the existing
  /// sync_surveys.py schema.
  Future<void> saveSurvey(String uid, Map<String, dynamic> surveyData) async {
    final data = Map<String, dynamic>.from(surveyData);
    final isChild = data.remove('isChild') as bool? ?? false;
    final guardianEmail = data.remove('guardianEmail') as String?;

    await _firestore.collection('users').doc(uid).update({
      'survey': {
        ...data,
        'completedAt': FieldValue.serverTimestamp(),
      },
      'surveyCompleted': true,
      'isChild': isChild,
      if (guardianEmail != null) 'guardianEmail': guardianEmail,
    });
  }

  /// Updates just the guardian email — used from Settings, independent
  /// of the survey flow (e.g. if the guardian's address changes later).
  Future<void> updateGuardianEmail(String uid, String email) async {
    await _firestore.collection('users').doc(uid).update({
      'guardianEmail': email,
    });
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}