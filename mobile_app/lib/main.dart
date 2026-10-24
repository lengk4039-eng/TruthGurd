import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/theme_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: TrustGuardApp()));
}

class TrustGuardApp extends ConsumerWidget {
  const TrustGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'TrustGuard Insurance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        final theme = Theme.of(context);
        return ColoredBox(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF0B0910)
              : const Color(0xFFEEEAF7),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) return child;
              return Center(
                child: Container(
                  width: 480,
                  height: constraints.maxHeight - 32,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
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
