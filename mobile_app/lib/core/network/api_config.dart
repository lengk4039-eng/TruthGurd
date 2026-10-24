import 'package:flutter/foundation.dart';

/// Resolves the API base URL per platform. Android emulators can't reach the
/// host machine via `localhost`, so they use the special `10.0.2.2` alias
/// instead; everything else (iOS simulator, web, desktop) uses `localhost`.
class ApiConfig {
  ApiConfig._();

  static const String _port = '8081';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$_port/api/v1';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:$_port/api/v1',
      _ => 'http://localhost:$_port/api/v1',
    };
  }
}
