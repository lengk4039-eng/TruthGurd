import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/payment/payment_success_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../models/installment_payment_result.dart';

class InstallmentResultScreen extends StatelessWidget {
  final InstallmentPaymentResult result;
  const InstallmentResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final payment = result.payment;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl + 8,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            PaymentSuccessHeader(
              title: l10n.tr('payment.successTitle'),
              message: l10n.tr('payment.successInstallment', {
                'policy': payment.policyName,
              }),
              badge: l10n.tr('payment.paymentComplete').toUpperCase(),
            ),
            const SizedBox(height: AppSpacing.xl),
            PaymentReceiptCard(
              title: l10n.tr('payment.receipt'),
              reference: result.reference,
              footer:
                  '${l10n.tr('payment.coverageActive')} ${l10n.tr('payment.receiptSaved')}',
              rows: [
                PaymentReceiptRow(
                  l10n.tr('payment.invoice'),
                  payment.invoiceNumber,
                ),
                PaymentReceiptRow(
                  l10n.tr('payment.policy'),
                  payment.policyName,
                ),
                PaymentReceiptRow(
                  l10n.tr('payment.amountPaid'),
                  AppFormatters.currency(payment.amount),
                  emphasize: true,
                ),
                PaymentReceiptRow(
                  l10n.tr('payment.paidWith'),
                  result.instrumentLabel,
                ),
                PaymentReceiptRow(
                  l10n.tr('payment.paymentDate'),
                  l10n.formatDate(result.paidAt),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: l10n.tr('payment.viewPolicy'),
              icon: Icons.shield_outlined,
              onPressed: () => context.go('/my-policies/${payment.policyId}'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => context.go('/payments'),
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: Text(l10n.tr('payment.backToPayments')),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => context.go('/home'),
              child: Text(l10n.tr('payment.backHome')),
            ),
          ],
        ),
      ),
    );
  }
}
