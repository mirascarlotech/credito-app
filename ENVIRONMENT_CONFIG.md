# Environment Configuration Guide

This app supports multiple environments (Development and Production) with different configurations.

## Configuration Files

- **`lib/src/config/env_config.dart`** - Base configuration class
- **`lib/src/config/dev_config.dart`** - Development environment settings
- **`lib/src/config/prod_config.dart`** - Production environment settings
- **`lib/src/config/config_provider.dart`** - Riverpod provider for accessing config throughout the app

## Entry Points

- **`lib/main_dev.dart`** - Development entry point
- **`lib/main_prod.dart`** - Production entry point
- **`lib/main.dart`** - Core app logic (shared)

## Running the App

### Development Mode
```bash
flutter run -t lib/main_dev.dart
```

### Production Mode
```bash
flutter run -t lib/main_prod.dart
```

## Building for Release

### Development Build (APK)
```bash
flutter build apk -t lib/main_dev.dart
```

### Production Build (APK)
```bash
flutter build apk -t lib/main_prod.dart --release
```

### Development Build (iOS)
```bash
flutter build ios -t lib/main_dev.dart
```

### Production Build (iOS)
```bash
flutter build ios -t lib/main_prod.dart --release
```

## VS Code / Android Studio

Launch configurations have been created in `.vscode/launch.json`. You can select:
- **Development** - Run in debug mode with dev config
- **Production** - Run in debug mode with prod config
- **Development (Profile)** - Run in profile mode with dev config
- **Production (Release)** - Run in release mode with prod config

## Accessing Configuration in Code

Use the `envConfigProvider` to access the current environment configuration:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:credito_app/src/config/config_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(envConfigProvider);
    
    // Access configuration values
    print('API Endpoint: ${config.chatApiEndpoint}');
    print('Environment: ${config.environment}');
    print('Debug Mode: ${config.debugMode}');
    
    return YourWidget();
  }
}
```

## Adding New Configuration Values

1. Add the new field to `EnvConfig` class in `lib/src/config/env_config.dart`
2. Add the value to `devConfig` in `lib/src/config/dev_config.dart`
3. Add the value to `prodConfig` in `lib/src/config/prod_config.dart`

Example:
```dart
// env_config.dart
class EnvConfig {
  final String chatApiEndpoint;
  final String environment;
  final bool debugMode;
  final String newValue; // Add new field
  
  const EnvConfig({
    required this.chatApiEndpoint,
    required this.environment,
    required this.debugMode,
    required this.newValue, // Add to constructor
  });
}
```

```dart
// dev_config.dart
const devConfig = EnvConfig(
  chatApiEndpoint: 'http://192.168.68.160:3000/v1/chat',
  environment: 'development',
  debugMode: true,
  newValue: 'dev-specific-value',
);
```

```dart
// prod_config.dart
const prodConfig = EnvConfig(
  chatApiEndpoint: 'https://api.credito.com/v1/chat',
  environment: 'production',
  debugMode: false,
  newValue: 'prod-specific-value',
);
```

