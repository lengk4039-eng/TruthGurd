import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/payment.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../models/checkout_selection.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final CheckoutSelection selection;
  const PaymentMethodScreen({super.key, required this.selection});

  @override
  ConsumerState<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  PaymentMethod _method = PaymentMethod.card;
  bool _isSubmitting = false;
  String? _error;

  Future<void> _pay() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final selection = widget.selection;
      final policy = await ref.read(policiesRepositoryProvider).purchasePackage(
            package: selection.package,
            plan: selection.plan,
            method: _method,
            addOns: selection.addOns,
            quotationId: selection.quotationId,
          );
      if (selection.quotationId != null) {
        await ref.read(quotationsRepositoryProvider).markAccepted(
              quotationId: selection.quotationId!,
              policyId: policy.id,
            );
      }
      invalidateAfterMutation(ref);
      if (selection.quotationId != null) {
        ref.invalidate(quotationDetailProvider(selection.quotationId!));
      }
      if (!mounted) return;
      context.pushReplacement(
        '/checkout/result',
        extra: PurchaseResult(
          policy: policy,
          method: _method,
          fromQuotation: selection.isFromQuotation,
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('AppException: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Payment method'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  for (final method in PaymentMethod.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _MethodTile(
                        method: method,
                        selected: _method == method,
                        onTap: () => setState(() => _method = method),
                      ),
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selection.isFromQuotation) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'Paying the sales-quoted price for ${selection.plan.label}',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total due today', style: Theme.of(context).textTheme.bodyMedium),
                      Text(AppFormatters.currency(selection.total), style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Pay ${AppFormatters.currency(selection.total)}',
                    isLoading: _isSubmitting,
                    onPressed: _pay,
                    icon: Icons.lock_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({required this.method, required this.selected, required this.onTap});

  IconData get _icon {
    switch (method) {
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_rounded;
      case PaymentMethod.eWallet:
        return Icons.account_balance_wallet_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? AppColors.primary : Theme.of(context).dividerColor, width: selected ? 1.6 : 1),
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(_icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(method.label, style: Theme.of(context).textTheme.titleSmall)),
            Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? AppColors.primary : Theme.of(context).disabledColor),
          ],
        ),
      ),
    );
  }
}
