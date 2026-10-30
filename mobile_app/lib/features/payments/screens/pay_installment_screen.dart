import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/payment.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/payment/payment_checkout_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/installment_payment_result.dart';

class PayInstallmentScreen extends ConsumerStatefulWidget {
  final String paymentId;
  const PayInstallmentScreen({super.key, required this.paymentId});

  @override
  ConsumerState<PayInstallmentScreen> createState() =>
      _PayInstallmentScreenState();
}

class _PayInstallmentScreenState extends ConsumerState<PayInstallmentScreen> {
  Payment? _paid;

  Future<void> _pay(Payment payment, PaymentMethod method) async {
    final updated = await ref
        .read(paymentsRepositoryProvider)
        .payNow(payment.id, method);
    ref.invalidate(paymentDetailProvider(payment.id));
    ref.invalidate(paymentsForPolicyProvider(payment.policyId));
    ref.invalidate(policyDetailProvider(payment.policyId));
    invalidateAfterMutation(ref);
    _paid = updated;
  }

  void _onPaid(Payment payment, PaymentMethod method, String instrumentLabel) {
    final paid = _paid ?? payment;
    context.pushReplacement(
      '/payments/${payment.id}/paid',
      extra: InstallmentPaymentResult(
        payment: paid,
        method: method,
        instrumentLabel: instrumentLabel,
        reference: payment.invoiceNumber,
        paidAt: paid.paidDate ?? DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final paymentAsync = ref.watch(paymentDetailProvider(widget.paymentId));
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.tr('payment.payInstallmentTitle')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Icon(Icons.lock_rounded, size: 19, color: AppColors.success),
          ),
        ],
      ),
      body: AsyncValueView(
        value: paymentAsync,
        onRetry: () => ref.invalidate(paymentDetailProvider(widget.paymentId)),
        builder: (payment) {
          if (payment.status == PaymentStatus.paid) {
            return _AlreadyPaid(payment: payment);
          }
          return SafeArea(
            top: false,
            child: PaymentCheckoutView(
              amount: payment.amount,
              reference: payment.invoiceNumber,
              notice: l10n.tr('payment.policyPaymentNote'),
              header: _InstallmentSummary(payment: payment),
              onPay: (method) => _pay(payment, method),
              onPaid: (method, instrument) =>
                  _onPaid(payment, method, instrument),
            ),
          );
        },
      ),
    );
  }
}

class _InstallmentSummary extends StatelessWidget {
  final Payment payment;

  const _InstallmentSummary({required this.payment});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF7FE), Color(0xFFF8FCFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 19,
                  color: AppColors.brandInk,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tr('payment.installment'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      payment.policyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: l10n.paymentStatus(payment.status)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tr('payment.amountDue'),
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 9.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.currency(payment.amount),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.tr('payment.dueDate'),
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 9.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.formatDate(payment.dueDate),
                    style: theme.textTheme.titleSmall?.copyWith(fontSize: 12.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.daysUntil(payment.dueDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10.5,
                      color: payment.dueDate.isBefore(DateTime.now())
                          ? AppColors.error
                          : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tr('payment.invoice'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payment.invoiceNumber,
                      style: theme.textTheme.titleSmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tr('payment.policy'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payment.policyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlreadyPaid extends StatelessWidget {
  final Payment payment;

  const _AlreadyPaid({required this.payment});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 38,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.tr('payment.statusPaidTitle'),
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.tr('payment.alreadyPaid'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => context.go('/payments/${payment.id}'),
              child: Text(l10n.tr('payment.viewReceipt')),
            ),
          ],
        ),
      ),
    );
  }
}
