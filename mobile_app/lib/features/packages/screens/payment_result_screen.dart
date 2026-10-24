import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/payment.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/primary_button.dart';
import '../models/checkout_selection.dart';

class PaymentResultScreen extends StatelessWidget {
  final PurchaseResult result;
  const PaymentResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final policy = result.policy;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: AppColors.success, size: 52),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Payment successful!', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                result.fromQuotation
                    ? "Your quotation is confirmed. You're covered under ${policy.package.name}."
                    : "You're covered under ${policy.package.name}.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
              const SizedBox(height: AppSpacing.xl),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _row(context, 'Policy number', policy.policyNumber),
                      const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Divider()),
                      _row(context, 'Coverage', AppFormatters.currencyWhole(policy.package.coverageAmount)),
                      const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Divider()),
                      _row(context, 'Amount charged', AppFormatters.currency(policy.totalPremium)),
                      const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Divider()),
                      _row(context, 'Paid via', result.method.label),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'View policy',
                onPressed: () => context.go('/my-policies/${policy.id}'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(onPressed: () => context.go('/my-policies'), child: const Text('My policies')),
              TextButton(onPressed: () => context.go('/home'), child: const Text('Back to Home')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
