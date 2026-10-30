import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/payment.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/primary_button.dart';

class PaymentDetailScreen extends ConsumerWidget {
  final String paymentId;
  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final paymentAsync = ref.watch(paymentDetailProvider(paymentId));
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.tr('payment.detailsTitle')),
      ),
      body: AsyncValueView(
        value: paymentAsync,
        onRetry: () => ref.invalidate(paymentDetailProvider(paymentId)),
        builder: (payment) => _PaymentDetailBody(payment: payment),
      ),
    );
  }
}

class _PaymentDetailBody extends StatelessWidget {
  final Payment payment;
  const _PaymentDetailBody({required this.payment});

  List<Color> get _gradient {
    switch (payment.status) {
      case PaymentStatus.paid:
        return const [Color(0xFF23C08F), Color(0xFF0B9A6A)];
      case PaymentStatus.overdue:
        return const [Color(0xFFF17C6E), Color(0xFFD34A4A)];
      case PaymentStatus.failed:
        return const [Color(0xFF8E8B9E), Color(0xFF615D70)];
      case PaymentStatus.pending:
        return AppColors.heroGradient;
    }
  }

  String _heroTitle(AppLocalizations l10n) {
    switch (payment.status) {
      case PaymentStatus.paid:
        return l10n.tr('payment.statusPaidTitle');
      case PaymentStatus.overdue:
        return l10n.tr('payment.overdueTitle');
      case PaymentStatus.failed:
        return l10n.tr('payment.failedTitle');
      case PaymentStatus.pending:
        return l10n.tr('payment.dueNowTitle');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isPaid = payment.status == PaymentStatus.paid;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: [
                _HeroCard(
                  payment: payment,
                  gradient: _gradient,
                  title: _heroTitle(l10n),
                ),
                const SizedBox(height: AppSpacing.lg),
                _DetailsCard(payment: payment),
                if (!isPaid) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.055),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 17,
                          color: AppColors.brandInk,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.tr('payment.policyPaymentNote'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _SupportCard(payment: payment),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
          if (!isPaid)
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.tr('payment.amountDue'),
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            AppFormatters.currency(payment.amount),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: 21,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm + 2),
                      PrimaryButton(
                        label: l10n.tr('payment.payNow'),
                        icon: Icons.lock_rounded,
                        onPressed: () =>
                            context.push('/payments/${payment.id}/pay'),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.tr('payment.secureNote'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Payment payment;
  final List<Color> gradient;
  final String title;

  const _HeroCard({
    required this.payment,
    required this.gradient,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final paid = payment.status == PaymentStatus.paid;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl + 2),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -46,
            top: -60,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.13),
                  width: 22,
                ),
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -90,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        paid ? Icons.check_rounded : Icons.schedule_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        l10n.paymentStatus(payment.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppFormatters.currency(payment.amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${payment.policyName} · ${payment.invoiceNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(
                      paid
                          ? Icons.event_available_rounded
                          : Icons.event_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      paid
                          ? l10n.tr('policy.paidOn', {
                              'date': l10n.formatDate(payment.paidDate!),
                            })
                          : '${l10n.tr('payment.dueDate')} · ${l10n.formatDate(payment.dueDate)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11.5,
                      ),
                    ),
                    const Spacer(),
                    if (!paid)
                      Text(
                        l10n.daysUntil(payment.dueDate),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final Payment payment;

  const _DetailsCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isPaid = payment.status == PaymentStatus.paid;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 19,
                color: AppColors.brandInk,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.tr('payment.invoiceLabel'),
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 14.5),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _row(context, l10n.tr('payment.invoice'), payment.invoiceNumber),
          const _Divider(),
          _row(context, l10n.tr('payment.policy'), payment.policyName),
          const _Divider(),
          _row(
            context,
            l10n.tr('payment.dueDate'),
            l10n.formatDate(payment.dueDate),
          ),
          if (isPaid) ...[
            const _Divider(),
            _row(
              context,
              l10n.tr('payment.paidOn'),
              l10n.formatDate(payment.paidDate!),
            ),
            if (payment.method != null) ...[
              const _Divider(),
              _row(
                context,
                l10n.tr('payment.method'),
                l10n.paymentMethodLabel(payment.method!),
              ),
            ],
            const _Divider(),
            _row(
              context,
              l10n.tr('payment.amountPaid'),
              AppFormatters.currency(payment.amount),
              emphasize: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool emphasize = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: emphasize
                ? theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.success,
                    fontSize: 13.5,
                  )
                : theme.textTheme.titleSmall?.copyWith(fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final Payment payment;

  const _SupportCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.softGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.brandInk,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tr('payment.needHelp'),
                  style: theme.textTheme.titleSmall?.copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.tr('payment.needHelpBody', {
                    'invoice': payment.invoiceNumber,
                  }),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
