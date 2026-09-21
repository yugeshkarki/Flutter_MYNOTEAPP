import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/notes_service.dart';

class NotesProvider extends ChangeNotifier {
  final NotesService _service;
  StreamSubscription<List<Note>>? _sub;

  String? _uid;
  List<Note> _notes = [];
  bool _loading = false;
  String? _error;

  NotesProvider(this._service);

  List<Note> get notes => _notes;
  bool get loading => _loading;
  String? get error => _error;

  /// Called whenever the logged-in user changes (null = signed out).
  void listenTo(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    _sub = null;
    _notes = [];
    _error = null;
    _loading = uid != null;
    if (uid == null) return;

    _sub = _service.streamNotes(uid).listen(
      (data) {
        _notes = data;
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _error = 'Could not load notes.';
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> add(String title, String content) {
    final uid = _uid;
    if (uid == null) return Future.value(false);
    final note = Note(
      id: '',
      uid: uid,
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );
    return _run(() => _service.addNote(note));
  }

  Future<bool> update(Note note, String title, String content) =>
      _run(() => _service.updateNote(note.id, title, content));

  Future<bool> delete(Note note) {
    // Remove locally first so the swiped item disappears immediately.
    _notes = _notes.where((n) => n.id != note.id).toList();
    notifyListeners();
    return _run(() => _service.deleteNote(note.id));
  }

  Future<bool> _run(Future<void> Function() action) async {
    try {
      await action();
      _error = null;
      return true;
    } catch (_) {
      _error = 'Action failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
