import 'package:credito_app/src/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Notifier to manage counter state
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    state++;
  }
}

// Provider for the counter
final counterProvider = NotifierProvider<CounterNotifier, int>(() {
  return CounterNotifier();
});

class HomeScreen extends ConsumerWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final counter = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: user.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
          data: (user) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (user != null) ...[
                  Text('Logged in as: ${user.email}'),
                  SizedBox(height: 20),
                  Text('Counter value: $counter'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(counterProvider.notifier).increment();
                    },
                    child: Text('Increment Counter'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Logout'),
                          content: const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                      if (shouldLogout == true) {
                        await FirebaseAuth.instance.signOut();
                        ref.read(loginProvider.notifier).reset();
                      }
                    },
                    child: Text('Logout'),
                  ),
                ] else ...[
                  Text('Not logged in'),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}