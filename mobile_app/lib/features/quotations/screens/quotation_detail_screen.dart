import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/insurance_category.dart';
import '../../../core/models/quotation.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../packages/models/checkout_selection.dart';

class QuotationDetailScreen extends ConsumerStatefulWidget {
  final String quotationId;
  const QuotationDetailScreen({super.key, required this.quotationId});

  @override
  ConsumerState<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends ConsumerState<QuotationDetailScreen> {
  bool _busy = false;

  Future<void> _decline() async {
    setState(() => _busy = true);
    try {
      await ref.read(quotationsRepositoryProvider).declineQuotation(widget.quotationId);
      ref.invalidate(quotationDetailProvider(widget.quotationId));
      ref.invalidate(myQuotationsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quotation declined.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _acceptAndPay(Quotation quote) {
    if (!quote.canAccept) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This quotation can no longer be accepted.')),
      );
      return;
    }
    final selection = CheckoutSelection.fromQuotation(quote);
    context.push('/checkout/payment-method', extra: selection);
  }

  @override
  Widget build(BuildContext context) {
    final quoteAsync = ref.watch(quotationDetailProvider(widget.quotationId));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Quotation'),
      ),
      body: AsyncValueView(
        value: quoteAsync,
        onRetry: () => ref.invalidate(quotationDetailProvider(widget.quotationId)),
        builder: (quote) => _buildBody(context, quote),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Quotation quote) {
    final muted = Theme.of(context).textTheme.bodySmall?.color;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Container(
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
                        Icon(quote.package.category.icon, color: Colors.white),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            quote.package.name,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                        StatusBadge(label: quote.status.label, subtle: false),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      quote.status.description,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                    ),
                    if (quote.quotedPremium != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text('Quoted premium', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                      Text(
                        AppFormatters.currency(quote.quotedPremium!),
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                      ),
                      if (quote.validUntil != null)
                        Text(
                          'Valid until ${AppFormatters.date(quote.validUntil!)}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoRow(label: 'Preferred term', value: '${quote.preferredPlanMonths} months'),
              _InfoRow(label: 'Requested', value: AppFormatters.date(quote.createdAt)),
              if (quote.notes.isNotEmpty) _InfoRow(label: 'Your notes', value: quote.notes),
              if (quote.salesNotes != null && quote.salesNotes!.isNotEmpty)
                _InfoRow(label: 'Sales notes', value: quote.salesNotes!),
              if (quote.policyId != null)
                _InfoRow(label: 'Linked policy', value: quote.policyId!),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Buy now is still available anytime from the package page. A quotation lets sales tailor the price before you pay.',
                style: TextStyle(color: muted, fontSize: 13, height: 1.45),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (quote.canAccept)
                  PrimaryButton(
                    label: 'Accept & pay',
                    icon: Icons.shopping_cart_checkout_rounded,
                    isLoading: _busy,
                    onPressed: _busy ? null : () => _acceptAndPay(quote),
                  ),
                if (quote.canAccept || quote.status == QuotationStatus.pending) ...[
                  if (quote.canAccept) const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: _busy ? null : _decline,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                    ),
                    child: const Text('Decline quotation'),
                  ),
                ],
                if (quote.status == QuotationStatus.expired || quote.status == QuotationStatus.rejected) ...[
                  PrimaryButton(
                    label: 'Request a new quotation',
                    icon: Icons.refresh_rounded,
                    onPressed: () => context.push('/packages/${quote.packageId}/quote'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => context.push('/packages/${quote.packageId}'),
                    child: const Text('View package'),
                  ),
                ],
                if (quote.status == QuotationStatus.pending)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      'We’ll notify you when the quote is ready.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, fontSize: 12.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
