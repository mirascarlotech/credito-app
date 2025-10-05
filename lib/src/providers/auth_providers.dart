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
    } on FirebaseAuthException catch(e) {
      state = state.copyWith(error: e.message);
    } catch(e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}

class LoginState {
  final String email;
  final String password;
  final String? error;
  final bool loading;

  LoginState({
    this.email = '',
    this.password = '',
    this.error,
    this.loading = false,
  });

  LoginState copyWith({
    String? email,
    String? password,
    String? error,
    bool? loading,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      error: error ?? this.error,
      loading: loading ?? this.loading,
    );
  }
}
