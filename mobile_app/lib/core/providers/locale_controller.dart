import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_localizations.dart';

const _languageKey = 'app_language';

/// Set once at startup from saved preferences so the first frame uses the
/// correct language without a flash of English.
final initialLanguageProvider = Provider<AppLanguage>(
  (ref) => AppLanguage.english,
);

class LocaleController extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => ref.watch(initialLanguageProvider);

  Future<void> setLanguage(AppLanguage language) async {
    if (state == language) return;
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.code);
  }

  Future<void> toggle() => setLanguage(
    state == AppLanguage.english ? AppLanguage.khmer : AppLanguage.english,
  );
}

final localeControllerProvider =
    NotifierProvider<LocaleController, AppLanguage>(LocaleController.new);

Future<AppLanguage> loadSavedLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  return AppLanguage.fromCode(prefs.getString(_languageKey));
}
