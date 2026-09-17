import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _subscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (Object error) {
        _error = _friendlyAuthError(error);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  final AuthService _authService;
  late final StreamSubscription<User?> _subscription;

  User? _user;
  bool _isLoading = true;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(
      () => _authService.signIn(email: email, password: password),
    );
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(
      () => _authService.signUp(email: email, password: password),
    );
  }

  Future<bool> signOut() async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      return true;
    } on FirebaseAuthException catch (error) {
      debugPrint('FIREBASE AUTH ERROR: ${error.code}');
      debugPrint('FIREBASE AUTH MESSAGE: ${error.message}');
      _error = 'Firebase error: ${error.code}';
      return false;
    }
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<UserCredential> Function() action) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      await action();
      return true;
    } on FirebaseAuthException catch (error) {
      _error = _friendlyAuthError(error);
      return false;
    } catch (_) {
      _error =
          'Something went wrong. Please check your connection and try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    _isLoading = false;
    notifyListeners();
  }

  String _friendlyAuthError(Object error) {
    if (error is! FirebaseAuthException) {
      return 'Authentication failed. Please try again.';
    }

    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
