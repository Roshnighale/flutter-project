import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notes(String uid) {
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  Stream<List<Note>> getNotes(String uid) {
    return _notes(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(Note.fromFirestore).toList(growable: false),
        );
  }

  Future<void> createNote({
    required String uid,
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    await _notes(uid).add({
      'title': title.trim(),
      'content': content.trim(),
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  Future<void> updateNote({
    required String uid,
    required String noteId,
    required String title,
    required String content,
  }) async {
    await _notes(uid).doc(noteId).update({
      'title': title.trim(),
      'content': content.trim(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteNote({
    required String uid,
    required String noteId,
  }) async {
    await _notes(uid).doc(noteId).delete();
  }
}
