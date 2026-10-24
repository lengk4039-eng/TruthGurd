import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/app_localizations.dart';
import 'core/providers/locale_controller.dart';
import 'core/providers/theme_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final language = await loadSavedLanguage();
  runApp(
    ProviderScope(
      overrides: [initialLanguageProvider.overrideWithValue(language)],
      child: const TrustGuardApp(),
    ),
  );
}

class TrustGuardApp extends ConsumerWidget {
  const TrustGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(localeControllerProvider);
    final isKhmer = language == AppLanguage.khmer;

    return MaterialApp.router(
      title: 'TrustGuard Insurance',
      debugShowCheckedModeBanner: false,
      theme: isKhmer ? AppTheme.lightKhmer : AppTheme.light,
      darkTheme: isKhmer ? AppTheme.darkKhmer : AppTheme.dark,
      themeMode: themeMode,
      locale: language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        final theme = Theme.of(context);
        return ColoredBox(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF0B0910)
              : const Color(0xFFEDE9F7),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) return child;
              return Center(
                child: Container(
                  width: 480,
                  height: constraints.maxHeight - 32,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 40,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
