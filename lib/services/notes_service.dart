import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

/// Talks to Firestore only. Notes are stored in the "notes" collection
/// and linked to the user through the "uid" field.
class NotesService {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('notes');

  // READ: real-time stream. Sorted on the device so no Firestore index is needed.
  Stream<List<Note>> streamNotes(String uid) {
    return _col.where('uid', isEqualTo: uid).snapshots().map((snap) {
      final list = snap.docs.map((d) => Note.fromJson(d.data(), d.id)).toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    });
  }

  // CREATE
  Future<void> addNote(Note note) => _col.add(note.toJson());

  // UPDATE
  Future<void> updateNote(String id, String title, String content) {
    return _col.doc(id).update({
      'title': title,
      'content': content,
      'updatedAt': Timestamp.now(),
    });
  }

  // DELETE
  Future<void> deleteNote(String id) => _col.doc(id).delete();
}
