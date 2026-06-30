// lib/shared/models/auth_state.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:doomguard/shared/models/app_user.dart';
import 'package:doomguard/shared/services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _appUser;
  bool _isFetchingUser = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  AppUser? get appUser => _appUser;
  bool get isFetchingUser => _isFetchingUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthState() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _appUser = null;
        _isFetchingUser = false;
        notifyListeners();
        return;
      }

      // Signed in — hold the router while we fetch Firestore
      _isFetchingUser = true;
      _status = AuthStatus.authenticated;
      notifyListeners();

      try {
        final doc = await _authService.getUserFromFirestore(firebaseUser.uid);
        _appUser = doc ?? _fallbackUser(firebaseUser);
        if (doc == null) {
          debugPrint('⚠️ No Firestore doc for UID: ${firebaseUser.uid}');
        }
      } catch (e, stack) {
        debugPrint('❌ getUserFromFirestore error: $e');
        debugPrint('$stack');
        _appUser = _fallbackUser(firebaseUser);
      } finally {
        _isFetchingUser = false;
        notifyListeners();
      }
    });
  }

  AppUser _fallbackUser(User firebaseUser) => AppUser(
    uid: firebaseUser.uid,
    name: firebaseUser.displayName ?? '',
    email: firebaseUser.email ?? '',
    photoUrl: firebaseUser.photoURL ?? '',
    createdAt: DateTime.now(),
    lastLogin: DateTime.now(),
    surveyCompleted: false,
  );

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      // authStateChanges() listener handles the rest
    } catch (e) {
      debugPrint('❌ signInWithGoogle error: $e');
      _errorMessage = 'Sign-in failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSurvey(Map<String, dynamic> surveyData) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await _authService.saveSurvey(uid, surveyData);
      _appUser = _appUser?.copyWith(surveyCompleted: true);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ saveSurvey error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint('❌ signOut error: $e');
      rethrow;
    }
  }
}