import 'package:credito_app/src/config/config_provider.dart';
import 'package:credito_app/src/config/env_config.dart';
import 'package:credito_app/src/navigation/main_navigation.dart';
import 'package:credito_app/src/pages/login_page.dart';
import 'package:credito_app/src/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';
import 'firebase_options.dart';

// Global variable to hold the configuration
late final EnvConfig appConfig;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure logging
  Logger.root.level = appConfig.debugMode ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('Stack trace:\n${record.stackTrace}');
    }
  });

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    ProviderScope(
      overrides: [envConfigProvider.overrideWithValue(appConfig)],
      child: MyApp(config: appConfig),
    ),
  );
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return user.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (user) {
        if (user != null) {
          return const MainNavigation();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class MyApp extends ConsumerWidget {
  final EnvConfig config;

  const MyApp({required this.config, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Credito - ${config.environment}',
      debugShowCheckedModeBanner: config.debugMode,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), useMaterial3: true),
      home: const AuthGate(),
    );
  }
}
