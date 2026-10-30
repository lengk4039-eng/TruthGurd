import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/payment.dart';
import '../../../core/models/policy.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/category_image.dart';
import '../../../core/widgets/payment/payment_checkout_view.dart';
import '../models/checkout_selection.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final CheckoutSelection selection;
  const PaymentMethodScreen({super.key, required this.selection});

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  late final String _reference;
  Policy? _policy;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _reference =
        'TG-${now.year}-${(now.millisecondsSinceEpoch ~/ 1000) % 1000000}';
  }

  Future<void> _pay(PaymentMethod method) async {
    final selection = widget.selection;
    final policy = await ref
        .read(policiesRepositoryProvider)
        .purchasePackage(
          package: selection.package,
          plan: selection.plan,
          method: method,
          addOns: selection.addOns,
          quotationId: selection.quotationId,
        );
    if (selection.quotationId != null) {
      await ref
          .read(quotationsRepositoryProvider)
          .markAccepted(
            quotationId: selection.quotationId!,
            policyId: policy.id,
          );
    }
    invalidateAfterMutation(ref);
    if (selection.quotationId != null) {
      ref.invalidate(quotationDetailProvider(selection.quotationId!));
    }
    _policy = policy;
  }

  void _onPaid(PaymentMethod method, String instrumentLabel) {
    final policy = _policy;
    if (policy == null) return;
    context.pushReplacement(
      '/checkout/result',
      extra: PurchaseResult(
        policy: policy,
        method: method,
        fromQuotation: widget.selection.isFromQuotation,
        instrumentLabel: instrumentLabel,
        reference: _reference,
        paidAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selection = widget.selection;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.tr('payment.checkoutTitle')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Icon(Icons.lock_rounded, size: 19, color: AppColors.success),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: PaymentCheckoutView(
          amount: selection.total,
          reference: _reference,
          notice: selection.isFromQuotation
              ? l10n.tr('payment.quotationNotice', {
                  'plan': l10n.tr('checkout.quotedPlan', {
                    'count': '${selection.plan.months}',
                  }),
                })
              : null,
          header: _OrderSummary(selection: selection),
          onPay: _pay,
          onPaid: _onPaid,
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CheckoutSelection selection;

  const _OrderSummary({required this.selection});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final package = selection.package;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: AppColors.softGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryImage(
                category: package.category,
                size: 58,
                radius: AppRadius.md,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            l10n.category(package.category).toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.tr('payment.orderSummary'),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      package.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      package.tagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
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
                      l10n.tr('payment.policyPlan'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selection.isFromQuotation
                          ? l10n.tr('checkout.quotedPlan', {
                              'count': '${selection.plan.months}',
                            })
                          : l10n.planLabel(selection.plan.months),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tr('payment.coverage'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppFormatters.currencyWhole(package.coverageAmount),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 12.5,
                        color: AppColors.brandInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (selection.addOns.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm + 2),
            Text(
              l10n.tr('payment.addOns', {
                'count': '${selection.addOns.length}',
              }),
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
