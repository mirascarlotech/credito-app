import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'env_config.dart';

// Global provider for accessing the environment config
final envConfigProvider = Provider<EnvConfig>((ref) {
  throw UnimplementedError('envConfigProvider must be overridden');
});
