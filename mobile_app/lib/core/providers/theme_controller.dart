import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'app_theme_mode';

/// Set once at startup from saved preferences so the first frame is already
/// in the chosen appearance instead of flashing the system default.
final initialThemeModeProvider = Provider<ThemeMode>(
  (ref) => ThemeMode.system,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(initialThemeModeProvider);

  Future<void> select(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<void> setDarkMode(bool enabled) =>
      select(enabled ? ThemeMode.dark : ThemeMode.light);

  Future<void> useSystemDefault() => select(ThemeMode.system);
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

Future<ThemeMode> loadSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_themeModeKey);
  return ThemeMode.values.firstWhere(
    (mode) => mode.name == saved,
    orElse: () => ThemeMode.system,
  );
}
