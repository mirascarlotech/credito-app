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
    state = state.copyWith(loading: true, error: null);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: state.email.trim(),
        password: state.password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    } catch (e) {
      state = state.copyWith(error: 'An unexpected error occurred. Please try again.');
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  String _getErrorMessage(FirebaseAuthException exception) {
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
        return 'Invalid email or password. Please check and try again.';
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
}

class LoginState {
  final String email;
  final String password;
  final String? error;
  final bool loading;

  LoginState({this.email = '', this.password = '', this.error, this.loading = false});

  LoginState copyWith({String? email, String? password, String? error, bool? loading}) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      error: error ?? this.error,
      loading: loading ?? this.loading,
    );
  }
}
