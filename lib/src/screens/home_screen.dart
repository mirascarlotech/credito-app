import 'package:credito_app/src/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      appBar: AppBar(
        title: Text(title),
      ),
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