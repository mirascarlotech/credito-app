import 'package:credito_app/src/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _obscurePasswordProvider = StateProvider.autoDispose<bool>((ref) => true);

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);
    final obscurePassword = ref.watch(_obscurePasswordProvider);

    Future<void> submit() async {
      final registered = await loginNotifier.register();
      if (!context.mounted || !registered) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created successfully.')));
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
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
                  Text(
                    'Sign up with your email',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use a valid email address and a password with at least 6 characters.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    onChanged: loginNotifier.setEmail,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: loginNotifier.setPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => ref.read(_obscurePasswordProvider.notifier).state = !obscurePassword,
                      ),
                    ),
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => submit(),
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
                      : ElevatedButton(onPressed: submit, child: const Text('Register')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
