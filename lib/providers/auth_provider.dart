import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription<User?>? _sub;

  User? _user;
  bool _initializing = true; // true until Firebase reports the saved session
  bool _busy = false;
  String? _error;

  AuthProvider(this._service) {
    _sub = _service.authState.listen((user) {
      _user = user;
      _initializing = false;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get initializing => _initializing;
  bool get busy => _busy;
  String? get error => _error;

  Future<bool> signIn(String email, String password) =>
      _run(() => _service.signIn(email, password));

  Future<bool> signUp(String email, String password) =>
      _run(() => _service.signUp(email, password));

  Future<void> signOut() => _service.signOut();

  Future<bool> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyMessage(e.code);
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  String _friendlyMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Authentication failed ($code).';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
