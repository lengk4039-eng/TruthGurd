import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/insurance_category.dart';
import '../../../core/models/quotation.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';

class MyQuotationsScreen extends ConsumerWidget {
  const MyQuotationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final quotesAsync = ref.watch(myQuotationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.tr('quotations.title')),
      ),
      body: AsyncValueView(
        value: quotesAsync,
        onRetry: () => ref.invalidate(myQuotationsProvider),
        builder: (quotes) {
          if (quotes.isEmpty) {
            return EmptyState(
              icon: Icons.request_quote_outlined,
              title: l10n.tr('quotations.emptyTitle'),
              message: l10n.tr('quotations.emptyBody'),
              actionLabel: l10n.tr('quotations.browse'),
              onAction: () => context.go('/packages'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myQuotationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: quotes.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final quote = quotes[index];
                return _QuotationCard(
                  quotation: quote,
                  onTap: () => context.push('/quotations/${quote.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _QuotationCard extends StatelessWidget {
  final Quotation quotation;
  final VoidCallback onTap;

  const _QuotationCard({required this.quotation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  quotation.package.category.icon,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quotation.package.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.tr('quotations.monthsShort', {'count': '${quotation.preferredPlanMonths}'})} · ${l10n.formatDate(quotation.createdAt)}',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    if (quotation.quotedPremium != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.tr('quotations.quoted', {
                          'amount': AppFormatters.currency(
                            quotation.quotedPremium!,
                          ),
                        }),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              StatusBadge(label: l10n.quotationStatus(quotation.status)),
            ],
          ),
        ),
      ),
    );
  }
}
