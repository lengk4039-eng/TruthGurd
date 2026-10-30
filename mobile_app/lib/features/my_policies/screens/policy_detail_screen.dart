import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/claim_eligibility.dart';
import '../../../core/models/payment.dart';
import '../../../core/models/policy.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/category_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_controller.dart';

const _supportPhone = '+855 87 908 470';
const _supportEmail = 'Insurancehelpcenter12@gmail.com';

Color _policyStatusColor(PolicyStatus status) => switch (status) {
  PolicyStatus.active => AppColors.success,
  PolicyStatus.pending => AppColors.warning,
  PolicyStatus.expired || PolicyStatus.cancelled => AppColors.error,
};

Color _paymentStatusColor(PaymentStatus status) => switch (status) {
  PaymentStatus.paid => AppColors.success,
  PaymentStatus.pending => AppColors.warning,
  PaymentStatus.overdue || PaymentStatus.failed => AppColors.error,
};

class PolicyDetailScreen extends ConsumerWidget {
  final String policyId;
  const PolicyDetailScreen({super.key, required this.policyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final policyAsync = ref.watch(policyDetailProvider(policyId));
    final holderName = ref.watch(authStateProvider)?.fullName;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.tr('policy.title')),
        actions: [
          IconButton(
            tooltip: l10n.tr('policy.getCopy'),
            onPressed: () {
              final policy = policyAsync.value;
              if (policy != null) _showCopySheet(context, policy);
            },
            icon: const Icon(Icons.file_download_outlined),
          ),
        ],
      ),
      body: AsyncValueView(
        value: policyAsync,
        onRetry: () => ref.invalidate(policyDetailProvider(policyId)),
        builder: (policy) =>
            _PolicyDetailBody(policy: policy, holderName: holderName),
      ),
    );
  }
}

class _PolicyDetailBody extends ConsumerWidget {
  final Policy policy;
  final String? holderName;

  const _PolicyDetailBody({required this.policy, this.holderName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final paymentsAsync = ref.watch(paymentsForPolicyProvider(policy.id));
    final eligibilityAsync = ref.watch(claimEligibilityProvider(policy.id));
    final lapsed =
        policy.status == PolicyStatus.expired ||
        policy.status == PolicyStatus.cancelled;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(policyDetailProvider(policy.id));
        ref.invalidate(paymentsForPolicyProvider(policy.id));
        ref.invalidate(claimEligibilityProvider(policy.id));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          _PolicyHeroCard(policy: policy),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _GradientActionButton(
                  label: l10n.tr('policy.viewIdCard'),
                  icon: Icons.badge_outlined,
                  onPressed: () => _showIdCardSheet(
                    context,
                    policy: policy,
                    holderName: holderName,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _OutlinedActionButton(
                  label: l10n.tr('policy.getCopy'),
                  icon: Icons.file_download_outlined,
                  onPressed: () => _showCopySheet(context, policy),
                ),
              ),
            ],
          ),
          if (lapsed) ...[
            const SizedBox(height: AppSpacing.lg),
            _LapsedCard(policy: policy),
          ],
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(
            title: l10n.tr('policy.overview'),
            subtitle: l10n.tr('policy.overviewSubtitle'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _OverviewCard(policy: policy, holderName: holderName),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(
            title: l10n.tr('policy.coverageBreakdown'),
            subtitle: l10n.tr('policy.coverageSubtitle'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _CoverageCard(policy: policy),
          if (!lapsed) ...[
            const SizedBox(height: AppSpacing.md),
            AsyncValueView(
              value: paymentsAsync,
              builder: (payments) =>
                  _NextPaymentCard(policy: policy, payments: payments),
            ),
            const SizedBox(height: AppSpacing.md),
            AsyncValueView(
              value: eligibilityAsync,
              onRetry: () =>
                  ref.invalidate(claimEligibilityProvider(policy.id)),
              builder: (eligibility) => _ClaimReadinessCard(
                eligibility: eligibility,
                onFile: () => context.push('/my-policies/${policy.id}/claim'),
                onPay: eligibility.overduePaymentId == null
                    ? null
                    : () => context.push(
                        '/payments/${eligibility.overduePaymentId}',
                      ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(
            title: l10n.tr('policy.paymentTracking'),
            subtitle: l10n.tr('policy.paymentTrackingSubtitle'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AsyncValueView(
            value: paymentsAsync,
            onRetry: () => ref.invalidate(paymentsForPolicyProvider(policy.id)),
            builder: (payments) =>
                _PaymentTrackingSection(policy: policy, payments: payments),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(
            title: l10n.tr('policy.benefits'),
            subtitle: l10n.tr('policy.benefitsIncluded', {
              'count': '${policy.package.benefits.length}',
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          _BenefitsCard(benefits: policy.package.benefits),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton.icon(
              onPressed: () => _showCopySheet(context, policy),
              icon: const Icon(Icons.support_agent_rounded, size: 18),
              label: Text(l10n.tr('claim.contactSupport')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyHeroCard extends StatelessWidget {
  final Policy policy;
  const _PolicyHeroCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final percent = (policy.paidProgress * 100).round();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: AppColors.policyGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -60,
            child: _HeroOrb(size: 180, opacity: 0.12),
          ),
          Positioned(
            left: -40,
            bottom: -70,
            child: _HeroOrb(size: 150, opacity: 0.08),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CategoryImage(
                      category: policy.package.category,
                      size: 46,
                      radius: 14,
                      borderColor: Colors.white.withValues(alpha: 0.55),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n
                                .category(policy.package.category)
                                .toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.9,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            policy.package.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: l10n.policyStatus(policy.status),
                      color: _policyStatusColor(policy.status),
                      subtle: false,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(
                      Icons.tag_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        policy.policyNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      onTap: () => _copy(context, policy.policyNumber),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 15,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.tr('policy.insuredSince', {
                    'date': l10n.formatDate(policy.startDate),
                  }),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _HeroStat(
                        label: l10n.tr('policy.totalCoverage'),
                        value: AppFormatters.currencyWhole(
                          policy.package.coverageAmount,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    Expanded(
                      child: _HeroStat(
                        label: l10n.tr('policy.totalPremium'),
                        value: AppFormatters.currencyWhole(policy.totalPremium),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    Expanded(
                      child: _HeroStat(
                        label: l10n.tr('policy.validUntil'),
                        value: l10n.formatDate(policy.endDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      l10n.tr('policy.premiumProgress'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: policy.paidProgress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${AppFormatters.currencyWhole(policy.amountPaid)} / ${AppFormatters.currencyWhole(policy.totalPremium)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroOrb extends StatelessWidget {
  final double size;
  final double opacity;

  const _HeroOrb({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _GradientActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        gradient: const LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _OutlinedActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.28)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final Policy policy;
  final String? holderName;

  const _OverviewCard({required this.policy, this.holderName});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final divider = Divider(
      height: 1,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        child: Column(
          children: [
            _OverviewRow(
              icon: Icons.person_outline_rounded,
              label: l10n.tr('policy.holder'),
              value: holderName ?? '—',
            ),
            divider,
            _OverviewRow(
              icon: Icons.tag_rounded,
              label: l10n.tr('policy.policyNumber'),
              value: policy.policyNumber,
            ),
            divider,
            _OverviewRow(
              icon: Icons.shield_outlined,
              label: l10n.tr('policy.category'),
              value: l10n.category(policy.package.category),
            ),
            divider,
            _OverviewRow(
              icon: Icons.event_available_outlined,
              label: l10n.tr('policy.startDate'),
              value: l10n.formatDate(policy.startDate),
            ),
            divider,
            _OverviewRow(
              icon: Icons.event_busy_outlined,
              label: l10n.tr('policy.endDate'),
              value: l10n.formatDate(policy.endDate),
            ),
            divider,
            _OverviewRow(
              icon: Icons.verified_outlined,
              label: l10n.tr('policy.status'),
              value: l10n.policyStatus(policy.status),
              valueColor: _policyStatusColor(policy.status),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _OverviewRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.brandInk),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverageCard extends StatelessWidget {
  final Policy policy;
  const _CoverageCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final percent = (policy.paidProgress * 100).round();
    final remaining = (policy.totalPremium - policy.amountPaid).clamp(
      0,
      policy.totalPremium,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tr('policy.totalCoverage'),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.currencyWhole(
                          policy.package.coverageAmount,
                        ),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.tr('policy.coverageNote'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: AppColors.brandInk,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  l10n.tr('policy.premiumProgress'),
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  '${AppFormatters.currencyWhole(policy.amountPaid)} / ${AppFormatters.currencyWhole(policy.totalPremium)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: policy.paidProgress,
                minHeight: 8,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$percent%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandInk,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 6),
            _BreakdownRow(
              label: l10n.tr('policy.premiumPaid'),
              value: AppFormatters.currency(policy.amountPaid),
              color: AppColors.success,
            ),
            _BreakdownRow(
              label: l10n.tr('policy.remaining'),
              value: AppFormatters.currency(remaining),
              color: AppColors.warning,
            ),
            _BreakdownRow(
              label: l10n.tr('policy.totalPremium'),
              value: AppFormatters.currency(policy.totalPremium),
            ),
            _BreakdownRow(
              label: l10n.tr('policy.duration'),
              value: l10n.tr('policy.months', {
                'count': '${policy.package.durationMonths}',
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _BreakdownRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LapsedCard extends StatelessWidget {
  final Policy policy;
  const _LapsedCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final note = policy.status == PolicyStatus.expired
        ? l10n.tr('policy.expiredNote', {
            'date': l10n.formatDate(policy.endDate),
          })
        : l10n.tr('policy.inactiveBody');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_busy_rounded,
                size: 20,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.policyStatus(policy.status),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(note, style: theme.textTheme.bodySmall?.copyWith(height: 1.5)),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: l10n.tr('policy.renew'),
            icon: Icons.autorenew_rounded,
            onPressed: () => context.push('/packages/${policy.package.id}'),
          ),
        ],
      ),
    );
  }
}

class _NextPaymentCard extends StatelessWidget {
  final Policy policy;
  final List<Payment> payments;
  const _NextPaymentCard({required this.policy, required this.payments});

  Payment? get _duePayment {
    final open = payments.where((p) => p.status != PaymentStatus.paid).toList()
      ..sort((a, b) {
        if (a.status == PaymentStatus.overdue &&
            b.status != PaymentStatus.overdue) {
          return -1;
        }
        if (b.status == PaymentStatus.overdue &&
            a.status != PaymentStatus.overdue) {
          return 1;
        }
        return a.dueDate.compareTo(b.dueDate);
      });
    return open.isEmpty ? null : open.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final due = _duePayment;

    if (due == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.tr('policy.allPaid'),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final overdue =
        due.status == PaymentStatus.overdue ||
        due.dueDate.isBefore(DateTime.now());
    final accent = overdue ? AppColors.error : AppColors.warning;

    return Card(
      color: overdue ? AppColors.error.withValues(alpha: 0.06) : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                overdue ? Icons.error_rounded : Icons.schedule_rounded,
                color: accent,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${overdue ? l10n.tr('policy.overduePayment') : l10n.tr('policy.nextPayment')} · ${AppFormatters.currency(due.amount)}',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.daysUntil(due.dueDate),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => context.push('/payments/${due.id}'),
              child: Text(l10n.tr('policy.payNow')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimReadinessCard extends StatelessWidget {
  final ClaimEligibility eligibility;
  final VoidCallback onFile;
  final VoidCallback? onPay;

  const _ClaimReadinessCard({
    required this.eligibility,
    required this.onFile,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final waiting = eligibility.eligible && eligibility.withinWaitingPeriod;
    final color = !eligibility.eligible
        ? AppColors.error
        : (waiting ? AppColors.warning : AppColors.success);
    final icon = !eligibility.eligible
        ? Icons.gpp_maybe_rounded
        : (waiting ? Icons.hourglass_top_rounded : Icons.verified_user_rounded);
    final title = !eligibility.eligible
        ? (eligibility.overduePaymentId != null
              ? l10n.tr('policy.overduePayment')
              : l10n.tr('policy.claimUnavailable'))
        : (waiting
              ? l10n.tr('policy.waitingPeriod')
              : l10n.tr('policy.claimProtection'));
    final body = !eligibility.eligible
        ? (eligibility.overduePaymentId != null
              ? l10n.tr('policy.settleToUnlock')
              : l10n.tr('policy.inactiveBody'))
        : (waiting
              ? l10n.tr('policy.waitingPeriodBody', {
                  'date': l10n.formatDate(
                    eligibility.waitingPeriodEndsAt ?? DateTime.now(),
                  ),
                  'days': '${eligibility.waitingPeriodDays}',
                })
              : l10n.tr('policy.claimProtectionBody'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(body, style: theme.textTheme.bodySmall?.copyWith(height: 1.5)),
          if (eligibility.overdueAmount != null) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.tr('policy.outstanding', {'amount': AppFormatters.currency(eligibility.overdueAmount!)})}'
              '${eligibility.overdueDueDate != null ? ' · ${l10n.tr('policy.dueOn', {'date': l10n.formatDate(eligibility.overdueDueDate!)})}' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (eligibility.eligible)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onFile,
                icon: const Icon(Icons.assignment_outlined, size: 18),
                label: Text(
                  waiting
                      ? l10n.tr('policy.fileAccidentClaim')
                      : l10n.tr('policy.fileClaim'),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                ),
              ),
            )
          else if (onPay != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPay,
                icon: const Icon(Icons.payments_rounded, size: 18),
                label: Text(l10n.tr('policy.payOverdue')),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  backgroundColor: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentTrackingSection extends StatelessWidget {
  final Policy policy;
  final List<Payment> payments;

  const _PaymentTrackingSection({required this.policy, required this.payments});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (payments.isEmpty) {
      return Card(
        child: EmptyState(
          icon: Icons.receipt_long_rounded,
          title: l10n.tr('policy.noPayments'),
          message: l10n.tr('policy.noPaymentsBody'),
        ),
      );
    }

    final sorted = [...payments]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final paidCount = sorted
        .where((p) => p.status == PaymentStatus.paid)
        .length;
    final pendingCount = sorted
        .where((p) => p.status == PaymentStatus.pending)
        .length;
    final overdueCount = sorted
        .where((p) => p.status == PaymentStatus.overdue)
        .length;
    final remaining = (policy.totalPremium - policy.amountPaid).clamp(
      0,
      policy.totalPremium,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TrackingStat(
                        label: l10n.tr('policy.paid'),
                        value: AppFormatters.currencyWhole(policy.amountPaid),
                        color: AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: _TrackingStat(
                        label: l10n.tr('policy.remaining'),
                        value: AppFormatters.currencyWhole(remaining),
                        color: AppColors.warning,
                      ),
                    ),
                    Expanded(
                      child: _TrackingStat(
                        label: l10n.tr('policy.total'),
                        value: AppFormatters.currencyWhole(policy.totalPremium),
                        color: AppColors.brandInk,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _CountChip(
                      label: l10n.paymentStatus(PaymentStatus.paid),
                      count: paidCount,
                      color: AppColors.success,
                    ),
                    _CountChip(
                      label: l10n.paymentStatus(PaymentStatus.pending),
                      count: pendingCount,
                      color: AppColors.warning,
                    ),
                    _CountChip(
                      label: l10n.paymentStatus(PaymentStatus.overdue),
                      count: overdueCount,
                      color: AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.tr('policy.installmentSchedule'),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < sorted.length; i++) ...[
          _InstallmentTimelineTile(
            payment: sorted[i],
            index: i + 1,
            isLast: i == sorted.length - 1,
            onTap: () => context.push('/payments/${sorted[i].id}'),
          ),
        ],
      ],
    );
  }
}

class _TrackingStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TrackingStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CountChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$count $label',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InstallmentTimelineTile extends StatelessWidget {
  final Payment payment;
  final int index;
  final bool isLast;
  final VoidCallback onTap;

  const _InstallmentTimelineTile({
    required this.payment,
    required this.index,
    required this.isLast,
    required this.onTap,
  });

  IconData get _statusIcon {
    switch (payment.status) {
      case PaymentStatus.paid:
        return Icons.check_circle_rounded;
      case PaymentStatus.pending:
        return Icons.schedule_rounded;
      case PaymentStatus.overdue:
        return Icons.error_rounded;
      case PaymentStatus.failed:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.color;
    final statusColor = _paymentStatusColor(payment.status);
    final canPay =
        payment.status == PaymentStatus.pending ||
        payment.status == PaymentStatus.overdue;
    final when =
        payment.status == PaymentStatus.paid && payment.paidDate != null
        ? l10n.tr('policy.paidOn', {'date': l10n.formatDate(payment.paidDate!)})
        : '${l10n.tr('policy.dueOn', {'date': l10n.formatDate(payment.dueDate)})} · ${l10n.daysUntil(payment.dueDate)}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_statusIcon, size: 16, color: statusColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: theme.dividerColor.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.tr('policy.installment', {'index': '$index'})} · ${payment.invoiceNumber}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                when,
                                style: TextStyle(color: muted, fontSize: 12),
                              ),
                              if (payment.method != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  l10n.paymentMethodShort(payment.method!),
                                  style: TextStyle(color: muted, fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppFormatters.currency(payment.amount),
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            StatusBadge(
                              label: l10n.paymentStatus(payment.status),
                              color: statusColor,
                            ),
                            if (canPay) ...[
                              const SizedBox(height: 6),
                              Text(
                                l10n.tr('common.payNow'),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  final List<String> benefits;
  const _BenefitsCard({required this.benefits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (benefits.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: AppSpacing.md,
        ),
        child: Column(
          children: [
            for (var i = 0; i < benefits.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          benefits[i],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (i != benefits.length - 1)
                Divider(
                  height: 1,
                  indent: 38,
                  color: theme.dividerColor.withValues(alpha: 0.6),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: AppColors.brandInk),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.copy_rounded,
                size: 17,
                color: AppColors.brandInk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _copy(BuildContext context, String value) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(context.l10n.tr('common.copied'))));
}

Future<void> _showIdCardSheet(
  BuildContext context, {
  required Policy policy,
  String? holderName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  gradient: const LinearGradient(
                    colors: AppColors.policyGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TRUSTGUARD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                l10n.tr('policy.idCardTitle'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: l10n.policyStatus(policy.status),
                          color: _policyStatusColor(policy.status),
                          subtle: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        CategoryImage(
                          category: policy.package.category,
                          size: 44,
                          radius: 12,
                          borderColor: Colors.white.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                policy.package.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                l10n.category(policy.package.category),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.tr('policy.policyNumber').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      policy.policyNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _HeroStat(
                            label: l10n.tr('policy.member'),
                            value: holderName ?? '—',
                          ),
                        ),
                        Expanded(
                          child: _HeroStat(
                            label: l10n.tr('policy.validUntil'),
                            value: l10n.formatDate(policy.endDate),
                          ),
                        ),
                        Expanded(
                          child: _HeroStat(
                            label: l10n.tr('payment.coverage'),
                            value: AppFormatters.currencyWhole(
                              policy.package.coverageAmount,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.tr('policy.idCardFooter'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontSize: 10.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _copy(sheetContext, policy.policyNumber),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: Text(l10n.tr('policy.copyNumber')),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(l10n.tr('common.close')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showCopySheet(BuildContext context, Policy policy) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tr('policy.copySheetTitle'),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.tr('policy.copySheetBody', {
                  'policy': policy.policyNumber,
                }),
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: AppSpacing.md),
              _ContactTile(
                icon: Icons.call_outlined,
                label: l10n.tr('policy.callSupport'),
                value: _supportPhone,
                onTap: () => _copy(sheetContext, _supportPhone),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ContactTile(
                icon: Icons.mail_outline_rounded,
                label: l10n.tr('policy.emailSupport'),
                value: _supportEmail,
                onTap: () => _copy(sheetContext, _supportEmail),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _copy(sheetContext, policy.policyNumber),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(l10n.tr('policy.copyNumber')),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
