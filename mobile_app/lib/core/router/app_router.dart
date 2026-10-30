import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_controller.dart';
import '../localization/app_localizations.dart';
import '../../features/auth/screens/link_existing_policy_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/my_policies/screens/my_policies_screen.dart';
import '../../features/my_policies/screens/policy_detail_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/packages/models/checkout_selection.dart';
import '../../features/packages/screens/checkout_screen.dart';
import '../../features/packages/screens/package_detail_screen.dart';
import '../../features/packages/screens/packages_list_screen.dart';
import '../../features/packages/screens/payment_method_screen.dart';
import '../../features/packages/screens/payment_result_screen.dart';
import '../../features/payments/models/installment_payment_result.dart';
import '../../features/payments/screens/installment_result_screen.dart';
import '../../features/payments/screens/pay_installment_screen.dart';
import '../../features/payments/screens/payment_detail_screen.dart';
import '../../features/payments/screens/payment_history_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/claims/screens/claim_detail_screen.dart';
import '../../features/claims/screens/file_claim_screen.dart';
import '../../features/claims/screens/my_claims_screen.dart';
import '../../features/quotations/screens/my_quotations_screen.dart';
import '../../features/quotations/screens/quotation_detail_screen.dart';
import '../../features/quotations/screens/request_quotation_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

const _authRoutes = {'/login', '/register'};
const _preAuthRoutes = {'/splash', '/onboarding'};

/// Guests can browse the catalogue but reach nothing tied to a person. A
/// package page is readable so the terms can be checked before signup;
/// anything deeper under it (checkout, quote) requires an account.
final RegExp _guestPackageDetailPath = RegExp(r'^/packages/[^/]+$');

bool _isGuestAccessible(String path) =>
    _authRoutes.contains(path) ||
    _preAuthRoutes.contains(path) ||
    path == '/home' ||
    path == '/packages' ||
    _guestPackageDetailPath.hasMatch(path);

/// Bridges Riverpod's [authStateProvider] to go_router's [refreshListenable]
/// so a login/logout re-runs `redirect` in place, instead of recreating the
/// whole router (which would reset the nav stack back to `/splash`).
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider) != null;
      final path = state.matchedLocation;
      if (!loggedIn) {
        return _isGuestAccessible(path) ? null : '/home';
      }
      if (_authRoutes.contains(path)) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/link-policy',
        builder: (context, state) => const LinkExistingPolicyScreen(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/packages/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            PackageDetailScreen(packageId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'checkout',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) =>
                CheckoutScreen(packageId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'quote',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) =>
                RequestQuotationScreen(packageId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/quotations',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MyQuotationsScreen(),
      ),
      GoRoute(
        path: '/quotations/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            QuotationDetailScreen(quotationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/claims',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MyClaimsScreen(),
      ),
      GoRoute(
        path: '/claims/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            ClaimDetailScreen(claimId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/my-policies/:id/claim',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            FileClaimScreen(policyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/checkout/payment-method',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final selection = state.extra;
          if (selection is! CheckoutSelection) {
            return const _MissingFlowStateScreen();
          }
          return PaymentMethodScreen(selection: selection);
        },
      ),
      GoRoute(
        path: '/checkout/result',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final result = state.extra;
          if (result is! PurchaseResult) return const _MissingFlowStateScreen();
          return PaymentResultScreen(result: result);
        },
      ),
      GoRoute(
        path: '/my-policies/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            PolicyDetailScreen(policyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/payments/:id/pay',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            PayInstallmentScreen(paymentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/payments/:id/paid',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final result = state.extra;
          if (result is! InstallmentPaymentResult) {
            return const _MissingFlowStateScreen();
          }
          return InstallmentResultScreen(result: result);
        },
      ),
      GoRoute(
        path: '/payments/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            PaymentDetailScreen(paymentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/packages',
                builder: (context, state) => const PackagesListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-policies',
                builder: (context, state) => const MyPoliciesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/payments',
                builder: (context, state) => const PaymentHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _MissingFlowStateScreen extends StatelessWidget {
  const _MissingFlowStateScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 40),
              const SizedBox(height: 12),
              Text(
                context.l10n.tr('common.missingFlow'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: Text(context.l10n.tr('common.backHome')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
