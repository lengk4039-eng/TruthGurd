import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/insurance_category.dart';
import '../../../core/models/insurance_package.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/mock_data.dart';

class RequestQuotationScreen extends ConsumerStatefulWidget {
  final String packageId;
  const RequestQuotationScreen({super.key, required this.packageId});

  @override
  ConsumerState<RequestQuotationScreen> createState() =>
      _RequestQuotationScreenState();
}

class _RequestQuotationScreenState
    extends ConsumerState<RequestQuotationScreen> {
  int _planIndex = 2;
  final _notesController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(InsurancePackage package) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final plans = MockData.planOptionsFor(package);
      final months = plans[_planIndex.clamp(0, plans.length - 1)].months;
      final quote = await ref
          .read(quotationsRepositoryProvider)
          .requestQuotation(
            packageId: package.id,
            preferredPlanMonths: months,
            notes: _notesController.text,
          );
      ref.invalidate(myQuotationsProvider);
      ref.invalidate(myNotificationsProvider);
      if (!mounted) return;
      context.pushReplacement('/quotations/${quote.id}');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final packageAsync = ref.watch(packageDetailProvider(widget.packageId));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(context.l10n.tr('quotations.requestTitle')),
      ),
      body: AsyncValueView(
        value: packageAsync,
        onRetry: () => ref.invalidate(packageDetailProvider(widget.packageId)),
        builder: (package) => _buildBody(context, package),
      ),
    );
  }

  Widget _buildBody(BuildContext context, InsurancePackage package) {
    final l10n = context.l10n;
    final plans = MockData.planOptionsFor(package);
    final safeIndex = _planIndex.clamp(0, plans.length - 1);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Card(
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
                          package.category.icon,
                          color: AppColors.brandInk,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.name,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              l10n.tr('quotations.fromPrice', {
                                'coverage': AppFormatters.currencyWhole(
                                  package.coverageAmount,
                                ),
                                'price': AppFormatters.currency(
                                  package.monthlyPrice,
                                ),
                              }),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.tr('quotations.preferredPlan'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.tr('quotations.salesAdjust'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < plans.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PlanOptionTile(
                    label: l10n.planLabel(plans[i].months),
                    subtitle: l10n.tr('quotations.listPrice', {
                      'count': '${plans[i].months}',
                      'amount': AppFormatters.currency(plans[i].totalPrice),
                    }),
                    badge: plans[i].badge == null
                        ? null
                        : l10n.tr('checkout.save15'),
                    selected: safeIndex == i,
                    onTap: () => setState(() => _planIndex = i),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.tr('quotations.notesForSales'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: l10n.tr('quotations.anythingKnow'),
                hint: l10n.tr('quotations.anythingHint'),
                controller: _notesController,
                maxLines: 4,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: PrimaryButton(
              label: l10n.tr('quotations.submitRequest'),
              isLoading: _submitting,
              icon: Icons.send_rounded,
              onPressed: _submitting ? null : () => _submit(package),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanOptionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const _PlanOptionTile({
    required this.label,
    required this.subtitle,
    this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : Theme.of(context).dividerColor.withValues(alpha: 0.4),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
