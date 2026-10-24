import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../auth/providers/auth_controller.dart';

const onboardingSeenKey = 'onboarding_seen';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNext();
  }

  Future<void> _decideNext() async {
    final restoreSession = ref.read(authStateProvider.notifier).restoreSession();
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool(onboardingSeenKey) ?? false;
    await Future.wait([restoreSession, Future.delayed(const Duration(milliseconds: 1400))]);
    if (!mounted) return;

    if (ref.read(authStateProvider) != null) {
      context.go('/home');
    } else {
      context.go(seenOnboarding ? '/login' : '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: AppColors.tileGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 30, offset: const Offset(0, 14))],
                ),
                child: const AppLogo(size: 96),
              ),
              const SizedBox(height: 20),
              const Text(
                'TrustGuard',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Protection you can trust',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
