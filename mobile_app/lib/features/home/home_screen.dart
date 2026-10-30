import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/insurance_category.dart';
import '../../core/models/payment.dart';
import '../../core/models/policy.dart';
import '../../core/providers/data_providers.dart';
import '../../core/providers/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/avatar_initials.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass/feature_card_carousel.dart';
import '../../core/widgets/glass/glass_card.dart';
import '../../core/widgets/glass/glass_icon.dart';
import '../../core/widgets/glass/reminder_banner.dart';
import '../../core/widgets/glass/upcoming_payments_card.dart';
import '../../core/widgets/section_header.dart';
import '../auth/providers/auth_controller.dart';
import '../auth/widgets/guest_auth_prompt.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.tr('home.goodMorning');
    if (hour < 18) return l10n.tr('home.goodAfternoon');
    return l10n.tr('home.goodEvening');
  }

  /// Runs [open] for a signed-in user; a guest gets the sign-up prompt.
  void _guardForAccount(
    BuildContext context,
    WidgetRef ref, {
    required String route,
    required VoidCallback open,
  }) {
    if (ref.read(authStateProvider) != null) {
      open();
      return;
    }
    promptGuestToSignIn(
      context,
      ref,
      titleKey: 'guest.tabTitle',
      bodyKey: 'guest.tabBody',
      resumeRoute: route,
    );
  }

  void _showSupport(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.tr('home.helpDialogTitle')),
        content: Text(l10n.tr('home.helpDialogBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.tr('common.gotIt')),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageSheet(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final l10n = context.l10n;
            final current = ref.watch(localeControllerProvider);
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tr('home.languageSheetTitle'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.tr('home.languageSheetBody'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (final language in AppLanguage.values)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _LanguageTile(
                            language: language,
                            selected: current == language,
                            onTap: () async {
                              await ref
                                  .read(localeControllerProvider.notifier)
                                  .setLanguage(language);
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final surface = theme.cardColor;
    final user = ref.watch(authStateProvider);
    final isGuest = user == null;
    // Every /me endpoint needs a token, so guests read no account data at all.
    final policiesAsync = isGuest ? null : ref.watch(myPoliciesProvider);
    final notificationsAsync = isGuest
        ? null
        : ref.watch(myNotificationsProvider);
    final hasUnread = notificationsAsync?.value?.any((n) => !n.isRead) ?? false;

    final quickActions =
        <({GlassIconKind kind, String label, VoidCallback onTap})>[
          (
            kind: GlassIconKind.shield,
            label: l10n.tr('home.quickPolicies'),
            onTap: () => _guardForAccount(
              context,
              ref,
              route: '/my-policies',
              open: () => context.go('/my-policies'),
            ),
          ),
          (
            kind: GlassIconKind.receipt,
            label: l10n.tr('home.quickClaims'),
            onTap: () => _guardForAccount(
              context,
              ref,
              route: '/claims',
              open: () => context.push('/claims'),
            ),
          ),
          (
            kind: GlassIconKind.wallet,
            label: l10n.tr('home.quickPay'),
            onTap: () => _guardForAccount(
              context,
              ref,
              route: '/payments',
              open: () => context.go('/payments'),
            ),
          ),
          (
            kind: GlassIconKind.person,
            label: l10n.tr('home.quickSupport'),
            onTap: () => _showSupport(context),
          ),
        ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(featuredPackagesProvider);
            if (isGuest) return;
            ref.invalidate(myPoliciesProvider);
            ref.invalidate(myPaymentsProvider);
            ref.invalidate(myNotificationsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              108,
            ),
            children: [
              Row(
                children: [
                  GlassCard(
                    tone: GlassTone.light,
                    blur: AppBlur.soft,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadius.pill),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: AvatarInitials(
                      initials: user?.initials ?? '?',
                      size: 44,
                      imageUrl: user?.avatarUrl,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(l10n),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          user?.fullName ?? l10n.tr('guest.name'),
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _GlassPill(
                    onTap: () => _showLanguageSheet(context, ref),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 16,
                          color:
                              GlassInk.surfaceIsDark(context, GlassTone.light)
                              ? AppColors.primary
                              : AppColors.primaryDark,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          l10n.isKhmer ? 'KH' : 'EN',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isGuest) ...[
                    const SizedBox(width: 8),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _GlassPill(
                          onTap: () => context.push('/notifications'),
                          child: SizedBox(
                            height: 22,
                            child: Center(
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 22,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ),
                        if (hasUnread)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(color: surface, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _CoverageHeroCard(policiesAsync: policiesAsync),
              if (!isGuest) const _DueReminder(),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, bounds) {
                  // Exactly two tiles fit the page; the rest are a swipe away.
                  final tileWidth = (bounds.maxWidth - AppSpacing.sm) / 2;
                  return SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      padding: EdgeInsets.zero,
                      itemCount: quickActions.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final action = quickActions[i];
                        return SizedBox(
                          width: tileWidth,
                          child: _QuickAction(
                            kind: action.kind,
                            label: action.label,
                            onTap: action.onTap,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              if (!isGuest) ...[
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: l10n.tr('home.activePolicies'),
                  actionLabel: l10n.tr('common.seeAll'),
                  onAction: () => context.go('/my-policies'),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.tr('home.activePoliciesSubtitle'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                AsyncValueView(
                  value: policiesAsync!,
                  builder: (policies) {
                    final active = policies
                        .where((p) => p.status == PolicyStatus.active)
                        .toList();
                    if (active.isEmpty) {
                      return EmptyState(
                        icon: Icons.shield_outlined,
                        title: l10n.tr('home.noActivePolicies'),
                        message: l10n.tr('home.noActivePoliciesMessage'),
                        actionLabel: l10n.tr('home.browsePackages'),
                        onAction: () => context.go('/packages'),
                      );
                    }
                    return SizedBox(
                      height: 184,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: active.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (context, i) => _ActivePolicyCard(
                          policy: active[i],
                          onTap: () =>
                              context.push('/my-policies/${active[i].id}'),
                        ),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: l10n.tr('home.featured'),
                actionLabel: l10n.tr('common.seeAll'),
                onAction: () => context.go('/packages'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Consumer(
                builder: (context, ref, _) {
                  final featured = ref.watch(featuredPackagesProvider);
                  return AsyncValueView(
                    value: featured,
                    builder: (packages) => FeatureCardCarousel(
                      packages: packages,
                      onOpen: (package) =>
                          context.push('/packages/${package.id}'),
                      onApply: (package) => _guardForAccount(
                        context,
                        ref,
                        route: '/packages/${package.id}/checkout',
                        open: () =>
                            context.push('/packages/${package.id}/checkout'),
                      ),
                    ),
                  );
                },
              ),
              if (!isGuest) ...[
                const SizedBox(height: AppSpacing.xl),
                _UpcomingPayments(),
              ],
              const SizedBox(height: AppSpacing.lg),
              _SupportCard(
                title: l10n.tr('home.supportTitle'),
                body: l10n.tr('home.supportBody'),
                action: l10n.tr('home.supportAction'),
                onTap: () => _showSupport(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brand = AppColors.brandOn(
      onDark: Theme.of(context).brightness == Brightness.dark,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.07)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? brand : Theme.of(context).dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                language == AppLanguage.khmer ? 'KH' : 'EN',
                style: TextStyle(
                  color: selected ? AppColors.onPrimary : brand,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.nativeName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    language.englishName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? brand : Theme.of(context).disabledColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// A frosted pill for the header's compact controls — the same glass as the
/// cards, at button size.
class _GlassPill extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _GlassPill({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      tone: GlassTone.light,
      blur: AppBlur.soft,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      onTap: onTap,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: GlassInk.primary(context, GlassTone.light),
          fontWeight: FontWeight.w600,
        ),
        child: IconTheme.merge(
          data: IconThemeData(
            color: GlassInk.primary(context, GlassTone.light),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CoverageHeroCard extends StatelessWidget {
  /// Null when browsing as a guest — there are no policies to summarise, so
  /// the card sells the account instead of reporting coverage.
  final AsyncValue<List<Policy>>? policiesAsync;
  const _CoverageHeroCard({required this.policiesAsync});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isGuest = policiesAsync == null;
    final policies = policiesAsync?.value ?? const <Policy>[];
    final active = policies
        .where((p) => p.status == PolicyStatus.active)
        .toList();
    final totalCoverage = active.fold<double>(
      0,
      (sum, p) => sum + p.package.coverageAmount,
    );
    final coverageLabel = active.isEmpty
        ? l10n.tr('home.noActiveCoverage')
        : active.length == 1
        ? l10n.tr('home.coverageAcrossOne')
        : l10n.tr('home.coverageAcrossMany', {'count': '${active.length}'});

    return GlassCard(
      tone: GlassTone.frost,
      blur: AppBlur.strong,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.hero)),
      lift: 2,
      padding: EdgeInsets.zero,
      // The same ramp the featured cards ride: cyan under the coverage amount,
      // cooling to electric blue behind the shield, so the two bright surfaces
      // read as one brand rather than two palettes.
      fill: AppColors.auroraFill(stops: const [0.0, 0.34, 0.74, 1.0]),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            top: -50,
            child: _glowCircle(150, Colors.white.withValues(alpha: 0.34)),
          ),
          Positioned(
            right: 28,
            bottom: -62,
            child: _glowCircle(
              120,
              AppColors.auroraViolet.withValues(alpha: 0.16),
            ),
          ),
          Positioned(
            right: 6,
            top: 34,
            child: Transform.rotate(
              angle: -0.08,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // White haze first, so the orb looks like it is lit from
                  // behind the card rather than stuck on top of it.
                  _glowCircle(176, Colors.white.withValues(alpha: 0.40)),
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.48),
                        width: 1.2,
                      ),
                    ),
                  ),
                  // The shield needs the deep end to stay legible: white on
                  // cyan is 1.7:1, white on electric blue is 5.2:1.
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment(-0.35, -0.45),
                        radius: 1.25,
                        colors: [
                          AppColors.primary,
                          AppColors.auroraBlue,
                          AppColors.primaryDark,
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                  const GlassIcon(
                    kind: GlassIconKind.shield,
                    size: 84,
                    tile: false,
                    bright: true,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 108, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGuest
                            ? Icons.visibility_outlined
                            : Icons.verified_user_rounded,
                        color: AppColors.onAurora,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isGuest
                            ? l10n.tr('guest.homeHeroPill')
                            : l10n.tr('home.protected'),
                        style: const TextStyle(
                          color: AppColors.onAurora,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (isGuest) ...[
                  Text(
                    l10n.tr('guest.homeHeroTitle'),
                    style: const TextStyle(
                      color: AppColors.onAurora,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.tr('guest.homeHeroBody'),
                    style: const TextStyle(
                      color: AppColors.onAuroraBody,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ] else ...[
                  Text(
                    l10n.tr('home.totalCoverage'),
                    style: const TextStyle(
                      color: AppColors.onAuroraBody,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppFormatters.currencyWhole(totalCoverage),
                      style: const TextStyle(
                        color: AppColors.onAurora,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coverageLabel,
                    style: const TextStyle(
                      color: AppColors.onAuroraBody,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _HeroButton(
                  label: isGuest
                      ? l10n.tr('guest.homeHeroAction')
                      : active.isEmpty
                      ? l10n.tr('home.browsePackages')
                      : l10n.tr('home.viewAllPolicies'),
                  onTap: () {
                    if (isGuest) {
                      context.push('/register');
                      return;
                    }
                    context.go(active.isEmpty ? '/packages' : '/my-policies');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A light source rather than a shape: the colour is strongest at the centre
  /// and gone by the rim, so the bloom never shows an edge on the gradient.
  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0.0, 0.72],
        ),
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _HeroButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadow.glow(AppColors.auroraBlue, radius: 20, y: 8),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.onAurora,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: AppColors.auroraBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final GlassIconKind kind;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.kind,
    required this.label,
    required this.onTap,
  });

  /// Strictly white and cyan. The white stops stay opaque so the blurred page
  /// wash can't grey the surface, and the brand cyan pools in the corner
  /// under the icon. Dark mode skips the ramp and keeps the deep-glass
  /// default, since the tone describes rank, not colour.
  static const _whiteCyan = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
      Color(0x8000D9FF),
    ],
    stops: [0.0, 0.45, 0.80, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GlassCard(
      tone: GlassTone.light,
      blur: AppBlur.soft,
      fill: isDark ? null : _whiteCyan,
      innerTint: isDark
          ? null
          : AppColors.primary.withValues(alpha: 0.16), // cyan rim, not grey
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      onTap: onTap,
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassIcon(kind: kind, size: 34, bright: true),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Component B wired to real data: the earliest instalment still unpaid.
class _DueReminder extends ConsumerWidget {
  const _DueReminder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(myPaymentsProvider).value ?? const <Payment>[];
    final due = payments.where((p) => p.status != PaymentStatus.paid).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (due.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: ReminderBanner(
        title: due.first.policyName,
        dueDate: due.first.dueDate,
        onTap: () => context.push('/payments/${due.first.id}'),
      ),
    );
  }
}

/// Component C wired to real data.
class _UpcomingPayments extends ConsumerWidget {
  const _UpcomingPayments();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final paymentsAsync = ref.watch(myPaymentsProvider);
    return AsyncValueView(
      value: paymentsAsync,
      builder: (payments) {
        final upcoming =
            payments.where((p) => p.status != PaymentStatus.paid).toList()
              ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        if (upcoming.isEmpty) {
          return EmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: l10n.tr('home.allCaughtUp'),
            message: l10n.tr('home.noPaymentsDue'),
          );
        }
        return UpcomingPaymentsCard(
          payments: upcoming.take(3).toList(),
          onTapPayment: (p) => context.push('/payments/${p.id}'),
          onSeeAll: () => context.go('/payments'),
        );
      },
    );
  }
}

class _ActivePolicyCard extends StatelessWidget {
  final Policy policy;
  final VoidCallback onTap;

  const _ActivePolicyCard({required this.policy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = (policy.paidProgress * 100).round();
    final radius = BorderRadius.circular(AppRadius.xl);
    return Container(
      width: 286,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadow.shadow(
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
      child: Material(
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                policy.package.category.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.30),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Text(
                            l10n.category(policy.package.category),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                l10n.policyStatus(policy.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      policy.package.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppFormatters.currencyWhole(policy.package.coverageAmount)} ${l10n.tr('payment.coverage').toLowerCase()}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: policy.paidProgress,
                              minHeight: 5,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.25,
                              ),
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$progress%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(color: AppColors.hairlineLight),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final String title;
  final String body;
  final String action;
  final VoidCallback onTap;

  const _SupportCard({
    required this.title,
    required this.body,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      tone: GlassTone.light,
      blur: AppBlur.medium,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const GlassIcon(kind: GlassIconKind.person, size: 46),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GlassCard(
            tone: GlassTone.dark,
            blur: AppBlur.soft,
            glow: AppColors.primary,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadius.pill),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            onTap: onTap,
            child: Text(
              action,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
