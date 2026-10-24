import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/claim_eligibility.dart';
import '../../../core/models/insurance_category.dart';
import '../../../core/models/payment.dart';
import '../../../core/models/policy.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_badge.dart';

class PolicyDetailScreen extends ConsumerWidget {
  final String policyId;
  const PolicyDetailScreen({super.key, required this.policyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policyAsync = ref.watch(policyDetailProvider(policyId));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Policy details'),
      ),
      body: AsyncValueView(
        value: policyAsync,
        onRetry: () => ref.invalidate(policyDetailProvider(policyId)),
        builder: (policy) => _PolicyDetailBody(policy: policy),
      ),
    );
  }
}

class _PolicyDetailBody extends ConsumerWidget {
  final Policy policy;
  const _PolicyDetailBody({required this.policy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsForPolicyProvider(policy.id));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(policyDetailProvider(policy.id));
        ref.invalidate(paymentsForPolicyProvider(policy.id));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _PolicyHeroCard(policy: policy),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _InfoTile(label: 'Coverage', value: AppFormatters.currencyWhole(policy.package.coverageAmount)),
              const SizedBox(width: AppSpacing.sm),
              _InfoTile(label: 'Start date', value: AppFormatters.dateShort(policy.startDate)),
              const SizedBox(width: AppSpacing.sm),
              _InfoTile(label: 'End date', value: AppFormatters.dateShort(policy.endDate)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (policy.status == PolicyStatus.expired)
            PrimaryButton(
              label: 'Renew this plan',
              icon: Icons.autorenew_rounded,
              onPressed: () => context.push('/packages/${policy.package.id}'),
            )
          else ...[
            AsyncValueView(
              value: paymentsAsync,
              builder: (payments) => _NextPaymentCard(policy: policy, payments: payments),
            ),
            const SizedBox(height: AppSpacing.sm),
            AsyncValueView(
              value: ref.watch(claimEligibilityProvider(policy.id)),
              onRetry: () => ref.invalidate(claimEligibilityProvider(policy.id)),
              builder: (eligibility) => _ClaimReadinessCard(
                eligibility: eligibility,
                onFile: () => context.push('/my-policies/${policy.id}/claim'),
                onPay: eligibility.overduePaymentId == null
                    ? null
                    : () => context.push('/payments/${eligibility.overduePaymentId}'),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text('Payment tracking', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          AsyncValueView(
            value: paymentsAsync,
            onRetry: () => ref.invalidate(paymentsForPolicyProvider(policy.id)),
            builder: (payments) => _PaymentTrackingSection(policy: policy, payments: payments),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Benefits', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final benefit in policy.package.benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(benefit, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
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
    final percent = (policy.paidProgress * 100).round();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: AppColors.tileGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(policy.package.category.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  policy.package.name,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
              StatusBadge(label: policy.status.label, subtle: false),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            policy.policyNumber,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Premium paid',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5),
              ),
              Text(
                '$percent%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: policy.paidProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${AppFormatters.currencyWhole(policy.amountPaid)} of ${AppFormatters.currencyWhole(policy.totalPremium)}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

/// Summary stats + chronological installment timeline for this policy.
class _PaymentTrackingSection extends StatelessWidget {
  final Policy policy;
  final List<Payment> payments;

  const _PaymentTrackingSection({required this.policy, required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'No payment schedule yet',
        message: 'Installments for this policy will show up here once billing starts.',
      );
    }

    final sorted = [...payments]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final paidCount = sorted.where((p) => p.status == PaymentStatus.paid).length;
    final pendingCount = sorted.where((p) => p.status == PaymentStatus.pending).length;
    final overdueCount = sorted.where((p) => p.status == PaymentStatus.overdue).length;
    final remaining = (policy.totalPremium - policy.amountPaid).clamp(0, policy.totalPremium);

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
                        label: 'Paid',
                        value: AppFormatters.currencyWhole(policy.amountPaid),
                        color: AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: _TrackingStat(
                        label: 'Remaining',
                        value: AppFormatters.currencyWhole(remaining),
                        color: AppColors.warning,
                      ),
                    ),
                    Expanded(
                      child: _TrackingStat(
                        label: 'Total',
                        value: AppFormatters.currencyWhole(policy.totalPremium),
                        color: AppColors.primary,
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
                    _CountChip(label: 'Paid', count: paidCount, color: AppColors.success),
                    _CountChip(label: 'Pending', count: pendingCount, color: AppColors.warning),
                    _CountChip(label: 'Overdue', count: overdueCount, color: AppColors.error),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Installment schedule', style: Theme.of(context).textTheme.titleSmall),
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

  const _TrackingStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CountChip({required this.label, required this.count, required this.color});

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
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
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

  Color get _statusColor => AppColors.forStatus(payment.status.label);

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
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final canPay = payment.status == PaymentStatus.pending || payment.status == PaymentStatus.overdue;

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
                    color: _statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_statusIcon, size: 16, color: _statusColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
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
                                'Installment #$index · ${payment.invoiceNumber}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                payment.status == PaymentStatus.paid && payment.paidDate != null
                                    ? 'Paid ${AppFormatters.date(payment.paidDate!)}'
                                    : 'Due ${AppFormatters.date(payment.dueDate)} · ${AppFormatters.daysUntil(payment.dueDate)}',
                                style: TextStyle(color: muted, fontSize: 12),
                              ),
                              if (payment.method != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  payment.method!.label,
                                  style: TextStyle(color: muted, fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppFormatters.currency(payment.amount),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            StatusBadge(label: payment.status.label),
                            if (canPay) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Pay now',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
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

class _NextPaymentCard extends StatelessWidget {
  final Policy policy;
  final List<Payment> payments;
  const _NextPaymentCard({required this.policy, required this.payments});

  Payment? get _duePayment {
    final open = payments.where((p) => p.status != PaymentStatus.paid).toList()
      ..sort((a, b) {
        // Overdue first, then by due date.
        if (a.status == PaymentStatus.overdue && b.status != PaymentStatus.overdue) return -1;
        if (b.status == PaymentStatus.overdue && a.status != PaymentStatus.overdue) return 1;
        return a.dueDate.compareTo(b.dueDate);
      });
    return open.isEmpty ? null : open.first;
  }

  @override
  Widget build(BuildContext context) {
    final due = _duePayment;
    if (due == null && (policy.nextPaymentDate == null || policy.nextPaymentAmount == null)) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'All installments for this period are paid.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final amount = due?.amount ?? policy.nextPaymentAmount!;
    final date = due?.dueDate ?? policy.nextPaymentDate!;
    final overdue = due?.status == PaymentStatus.overdue || date.isBefore(DateTime.now());

    return Card(
      color: overdue ? AppColors.error.withValues(alpha: 0.06) : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              overdue ? Icons.error_rounded : Icons.schedule_rounded,
              color: overdue ? AppColors.error : AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${overdue ? 'Overdue' : 'Next'} payment · ${AppFormatters.currency(amount)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(AppFormatters.daysUntil(date), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (due != null)
              FilledButton(
                onPressed: () => context.push('/payments/${due.id}'),
                child: const Text('Pay now'),
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
    final waiting = eligibility.eligible && eligibility.withinWaitingPeriod;
    final color = !eligibility.eligible
        ? AppColors.error
        : (waiting ? AppColors.warning : AppColors.success);
    final icon = !eligibility.eligible
        ? Icons.gpp_maybe_rounded
        : (waiting ? Icons.hourglass_top_rounded : Icons.verified_user_rounded);
    final title = !eligibility.eligible
        ? (eligibility.title.isEmpty ? 'Claim filing unavailable' : eligibility.title)
        : (waiting ? 'Waiting period active' : 'Claim protection active');

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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            eligibility.message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          if (eligibility.overdueAmount != null) ...[
            const SizedBox(height: 8),
            Text(
              'Outstanding ${AppFormatters.currency(eligibility.overdueAmount!)}'
              '${eligibility.overdueDueDate != null ? ' · due ${AppFormatters.date(eligibility.overdueDueDate!)}' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (eligibility.eligible)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onFile,
                icon: const Icon(Icons.assignment_outlined, size: 18),
                label: Text(waiting ? 'File an accident claim' : 'File a claim'),
                style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 46)),
              ),
            )
          else if (onPay != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPay,
                icon: const Icon(Icons.payments_rounded, size: 18),
                label: const Text('Pay overdue installment'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  backgroundColor: AppColors.error,
                ),
              ),
            )
          else
            Text(
              'Settle the outstanding premium below to unlock claim filing.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Text(value, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 10.5)),
          ],
        ),
      ),
    );
  }
}
