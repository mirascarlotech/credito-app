import 'package:credito_app/src/pages/register_page.dart';
import 'package:credito_app/src/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _obscurePasswordProvider = StateProvider.autoDispose<bool>((ref) => true);

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final obscurePassword = ref.watch(_obscurePasswordProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    onChanged: authNotifier.setEmail,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: authNotifier.setPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => ref.read(_obscurePasswordProvider.notifier).state = !obscurePassword,
                      ),
                    ),
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => authNotifier.login(),
                  ),
                  const SizedBox(height: 24),
                  if (loginState.error != null) ...[
                    Text(
                      loginState.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  loginState.loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(onPressed: authNotifier.login, child: const Text('Login')),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      authNotifier.reset();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
                    },
                    child: const Text('Create account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
