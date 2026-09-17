import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class NoteProvider extends ChangeNotifier {
  NoteProvider({
    FirestoreService? firestoreService,
    AuthService? authService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _authService = authService ?? AuthService() {
    _authSubscription = _authService.authStateChanges.listen(_handleUser);
  }

  final FirestoreService _firestoreService;
  final AuthService _authService;
  late final StreamSubscription<User?> _authSubscription;
  StreamSubscription<List<Note>>? _notesSubscription;

  List<Note> _notes = const [];
  bool _isLoading = false;
  bool _isMutating = false;
  String? _error;

  List<Note> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  String? get error => _error;

  Future<void> createNote({
    required String title,
    required String content,
  }) async {
    final uid = _requireUid();
    await _runMutation(
      () => _firestoreService.createNote(
        uid: uid,
        title: title,
        content: content,
      ),
    );
  }

  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) async {
    final uid = _requireUid();
    await _runMutation(
      () => _firestoreService.updateNote(
        uid: uid,
        noteId: noteId,
        title: title,
        content: content,
      ),
    );
  }

  Future<void> deleteNote(String noteId) async {
    final uid = _requireUid();
    await _runMutation(
      () => _firestoreService.deleteNote(uid: uid, noteId: noteId),
    );
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void _handleUser(User? user) {
    _notesSubscription?.cancel();
    _notesSubscription = null;
    _notes = const [];
    _error = null;

    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _notesSubscription = _firestoreService.getNotes(user.uid).listen(
      (notes) {
        _notes = notes;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _error = _friendlyFirestoreError(error);
        notifyListeners();
      },
    );
  }

  Future<void> _runMutation(Future<void> Function() action) async {
    if (_isMutating) return;

    _error = null;
    _isMutating = true;
    notifyListeners();

    try {
      await action();
    } on FirebaseException catch (error) {
      _error = _friendlyFirestoreError(error);
      rethrow;
    } catch (_) {
      _error = 'The note could not be saved. Please try again.';
      rethrow;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  String _requireUid() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      throw StateError('You must be signed in to manage notes.');
    }
    return uid;
  }

  String _friendlyFirestoreError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to access these notes.';
        case 'unavailable':
        case 'deadline-exceeded':
          return 'The service is temporarily unavailable. Check your connection.';
        default:
          return 'Could not access your notes. Please try again.';
      }
    }
    return 'Could not access your notes. Please try again.';
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _notesSubscription?.cancel();
    super.dispose();
  }
}
