import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/glass/aquatic_nav_bar.dart';
import '../../core/widgets/glass/app_backdrop.dart';
import '../../core/widgets/glass/glass_icon.dart';
import '../auth/providers/auth_controller.dart';
import '../auth/widgets/guest_auth_prompt.dart';

/// Branches that show private, account-owned data.
const Set<int> _guestLockedBranches = {2, 3, 4};

/// The bar has four side tabs and a centre button, but the router keeps five
/// branches so deep links and resume routes are unaffected. Slot order here is
/// the visual order; `branch` is what `goBranch` receives.
class _Tabs {
  static const home = NavTab(
    kind: GlassIconKind.house,
    label: 'home',
    branch: 0,
  );
  static const policies = NavTab(
    kind: GlassIconKind.shield,
    label: 'policies',
    branch: 2,
  );
  static const cover = NavTab(
    kind: GlassIconKind.bag,
    label: 'cover',
    branch: 1,
  );
  static const payments = NavTab(
    kind: GlassIconKind.wallet,
    label: 'payments',
    branch: 3,
  );
  static const profile = NavTab(
    kind: GlassIconKind.person,
    label: 'profile',
    branch: 4,
  );
}

class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isGuest = ref.watch(authStateProvider) == null;
    final active = navigationShell.currentIndex;

    NavTab named(NavTab tab, String key) => NavTab(
      kind: tab.kind,
      label: l10n.tr(key),
      branch: tab.branch,
    );

    void select(NavTab tab) {
      if (isGuest && _guestLockedBranches.contains(tab.branch)) {
        promptGuestToSignIn(
          context,
          ref,
          titleKey: 'guest.tabTitle',
          bodyKey: 'guest.tabBody',
          resumeRoute: _routeForBranch(tab.branch),
        );
        return;
      }
      navigationShell.goBranch(
        tab.branch,
        initialLocation: tab.branch == active,
      );
    }

    return AppBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: AquaticNavBar(
            activeBranch: active,
            onSelect: select,
            leftTabs: [
              named(_Tabs.home, 'nav.home'),
              named(_Tabs.policies, 'nav.policies'),
            ],
            rightTabs: [
              named(_Tabs.payments, 'nav.payments'),
              named(_Tabs.profile, 'nav.profile'),
            ],
            center: named(_Tabs.cover, 'nav.packages'),
          ),
        ),
      ),
    );
  }
}

String _routeForBranch(int branch) {
  switch (branch) {
    case 2:
      return '/my-policies';
    case 3:
      return '/payments';
    default:
      return '/profile';
  }
}
