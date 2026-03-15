import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

final userProvider = StreamProvider.autoDispose<User?>((ref) async* {
  final authStream = FirebaseAuth.instance.authStateChanges();
  final idTokenStream = FirebaseAuth.instance.idTokenChanges();
  final userStream = FirebaseAuth.instance.userChanges();

  await for (final user in Rx.merge([authStream, idTokenStream, userStream])) {
    yield user;
  }
});

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(() => LoginNotifier());

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => LoginState();

  void setEmail(String email) => state = state.copyWith(email: email);
  void setPassword(String password) => state = state.copyWith(password: password);

  void reset() => state = LoginState();

  Future<void> login() async {
    final validationError = _validateCredentials();
    if (validationError != null) {
      state = state.copyWith(error: validationError, loading: false);
      return;
    }

    state = state.copyWith(loading: true, error: null);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: state.email.trim(),
        password: state.password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(error: _getLoginErrorMessage(e));
    } catch (e) {
      state = state.copyWith(error: 'An unexpected error occurred. Please try again.');
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<bool> register() async {
    final validationError = _validateCredentials(requireMinPasswordLength: true);
    if (validationError != null) {
      state = state.copyWith(error: validationError, loading: false);
      return false;
    }

    state = state.copyWith(loading: true, error: null);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: state.email.trim(),
        password: state.password.trim(),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(error: _getRegistrationErrorMessage(e));
      return false;
    } catch (e) {
      state = state.copyWith(error: 'An unexpected error occurred. Please try again.');
      return false;
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  String? _validateCredentials({bool requireMinPasswordLength = false}) {
    final email = state.email.trim();
    final password = state.password.trim();

    if (email.isEmpty || password.isEmpty) {
      return 'Please enter both your email and password.';
    }

    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address.';
    }

    if (requireMinPasswordLength && password.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    return null;
  }

  bool _isValidEmail(String email) {
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailPattern.hasMatch(email);
  }

  String _getLoginErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return 'The email address is invalid. Please check and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'That email or password doesn\'t match our records. Please try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not available. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      case 'invalid-api-key':
        return 'Service configuration error. Please contact support.';
      case 'app-not-authorized':
        return 'App is not authorized. Please contact support.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  String _getRegistrationErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email. Try logging in instead.';
      case 'invalid-email':
        return 'The email address is invalid. Please check and try again.';
      case 'weak-password':
        return 'Choose a stronger password with at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password registration is not available right now. Please contact support.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      default:
        return 'Registration failed. Please try again.';
    }
  }
}

class LoginState {
  static const _unset = Object();

  final String email;
  final String password;
  final String? error;
  final bool loading;

  LoginState({this.email = '', this.password = '', this.error, this.loading = false});

  LoginState copyWith({String? email, String? password, Object? error = _unset, bool? loading}) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      error: identical(error, _unset) ? this.error : error as String?,
      loading: loading ?? this.loading,
    );
  }
}
