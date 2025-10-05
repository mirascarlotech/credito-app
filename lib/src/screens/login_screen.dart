import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(() => LoginNotifier());

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: loginNotifier.setEmail,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: loginNotifier.setPassword,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (loginState.error != null) ...[
              Text(loginState.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
            ],
            loginState.loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: loginNotifier.login,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
