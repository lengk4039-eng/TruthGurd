import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/payment.dart';
import '../../core/models/policy.dart';
import '../../core/providers/data_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/avatar_initials.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/package_card.dart';
import '../../core/widgets/payment_tile.dart';
import '../../core/widgets/policy_card.dart';
import '../../core/widgets/section_header.dart';
import '../auth/providers/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final policiesAsync = ref.watch(myPoliciesProvider);
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final hasUnread = notificationsAsync.value?.any((n) => !n.isRead) ?? false;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myPoliciesProvider);
            ref.invalidate(featuredPackagesProvider);
            ref.invalidate(myPaymentsProvider);
            ref.invalidate(myNotificationsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
            children: [
              Row(
                children: [
                  AvatarInitials(initials: user?.initials ?? '?', size: 46),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting(), style: Theme.of(context).textTheme.bodySmall),
                        Text(user?.fullName ?? '', style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => context.push('/notifications'),
                        icon: const Icon(Icons.notifications_outlined),
                      ),
                      if (hasUnread)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _CoverageHeroCard(policiesAsync: policiesAsync),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: _QuickAction(icon: Icons.add_shopping_cart_rounded, label: 'Buy new', onTap: () => context.go('/packages'))),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _QuickAction(icon: Icons.shield_rounded, label: 'My policies', onTap: () => context.go('/my-policies'))),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _QuickAction(icon: Icons.payments_rounded, label: 'Payments', onTap: () => context.go('/payments'))),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.support_agent_rounded,
                      label: 'Support',
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Need help?'),
                          content: const Text(
                            'Our support team is available 24/7.\n\nPhone: +855 87 908 470\nEmail: Insurancehelpcenter12@gmail.com',
                          ),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: 'Featured for you', actionLabel: 'See all', onAction: () => context.go('/packages')),
              const SizedBox(height: AppSpacing.md),
              Consumer(builder: (context, ref, _) {
                final featured = ref.watch(featuredPackagesProvider);
                return AsyncValueView(
                  value: featured,
                  builder: (packages) => SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: packages.length,
                      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, i) => PackageCard(
                        package: packages[i],
                        featured: true,
                        onTap: () => context.push('/packages/${packages[i].id}'),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: 'Your policies', actionLabel: 'See all', onAction: () => context.go('/my-policies')),
              const SizedBox(height: AppSpacing.md),
              AsyncValueView(
                value: policiesAsync,
                builder: (policies) {
                  final active = policies.where((p) => p.status == PolicyStatus.active).take(2).toList();
                  if (active.isEmpty) {
                    return EmptyState(
                      icon: Icons.shield_outlined,
                      title: 'No active policies yet',
                      message: 'Browse our plans and get covered in a few minutes.',
                      actionLabel: 'Browse packages',
                      onAction: () => context.go('/packages'),
                    );
                  }
                  return Column(
                    children: [
                      for (final p in active) ...[
                        PolicyCard(policy: p, onTap: () => context.push('/my-policies/${p.id}')),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Upcoming payments'),
              const SizedBox(height: AppSpacing.md),
              Consumer(builder: (context, ref, _) {
                final paymentsAsync = ref.watch(myPaymentsProvider);
                return AsyncValueView(
                  value: paymentsAsync,
                  builder: (payments) {
                    final upcoming = payments.where((p) => p.status != PaymentStatus.paid).take(2).toList();
                    if (upcoming.isEmpty) {
                      return EmptyState(icon: Icons.check_circle_outline_rounded, title: "You're all caught up", message: 'No payments due right now.');
                    }
                    return Column(
                      children: [
                        for (final p in upcoming) ...[
                          PaymentTile(payment: p, onTap: () => context.push('/payments/${p.id}')),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverageHeroCard extends StatelessWidget {
  final AsyncValue<List<Policy>> policiesAsync;
  const _CoverageHeroCard({required this.policiesAsync});

  @override
  Widget build(BuildContext context) {
    final policies = policiesAsync.value ?? const [];
    final active = policies.where((p) => p.status == PolicyStatus.active).toList();
    final totalCoverage = active.fold<double>(0, (sum, p) => sum + p.package.coverageAmount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(colors: AppColors.tileGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 22, offset: const Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Colors.white.withValues(alpha: 0.9), size: 18),
              const SizedBox(width: 6),
              Text("You're protected", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppFormatters.currencyWhole(totalCoverage),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
          ),
          Text('total coverage across ${active.length} active ${active.length == 1 ? 'policy' : 'policies'}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
