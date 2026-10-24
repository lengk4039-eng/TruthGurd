import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/payment.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_badge.dart';

class PaymentDetailScreen extends ConsumerWidget {
  final String paymentId;
  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentAsync = ref.watch(paymentDetailProvider(paymentId));
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Payment details'),
      ),
      body: AsyncValueView(
        value: paymentAsync,
        onRetry: () => ref.invalidate(paymentDetailProvider(paymentId)),
        builder: (payment) => _PaymentDetailBody(payment: payment),
      ),
    );
  }
}

class _PaymentDetailBody extends ConsumerStatefulWidget {
  final Payment payment;
  const _PaymentDetailBody({required this.payment});

  @override
  ConsumerState<_PaymentDetailBody> createState() => _PaymentDetailBodyState();
}

class _PaymentDetailBodyState extends ConsumerState<_PaymentDetailBody> {
  PaymentMethod _method = PaymentMethod.card;
  bool _isSubmitting = false;

  Future<void> _payNow() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(paymentsRepositoryProvider).payNow(widget.payment.id, _method);
      ref.invalidate(paymentDetailProvider(widget.payment.id));
      invalidateAfterMutation(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('AppException: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final isPaid = payment.status == PaymentStatus.paid;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(color: AppColors.forStatus(payment.status.label).withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(
                  isPaid ? Icons.receipt_long_rounded : Icons.hourglass_bottom_rounded,
                  color: AppColors.forStatus(payment.status.label),
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(AppFormatters.currency(payment.amount), style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 4),
              StatusBadge(label: payment.status.label),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _row(context, 'Invoice number', payment.invoiceNumber),
                const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Divider()),
                _row(context, 'Policy', payment.policyName),
                const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Divider()),
                _row(context, 'Due date', AppFormatters.date(payment.dueDate)),
                if (isPaid) ...[
                  const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Divider()),
                  _row(context, 'Paid on', AppFormatters.date(payment.paidDate!)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Divider()),
                  _row(context, 'Payment method', payment.method?.label ?? '—'),
                ],
              ],
            ),
          ),
        ),
        if (!isPaid) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('Pay with', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final method in PaymentMethod.values)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: RadioListTile<PaymentMethod>(
                value: method,
                groupValue: _method,
                onChanged: (v) => setState(() => _method = v!),
                title: Text(method.label),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(label: 'Pay ${AppFormatters.currency(payment.amount)}', isLoading: _isSubmitting, onPressed: _payNow),
        ],
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
        Flexible(child: Text(value, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.end)),
      ],
    );
  }
}
