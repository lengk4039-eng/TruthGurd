import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/insurance_category.dart';
import '../../../core/models/insurance_package.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/mock_data.dart';
import '../models/checkout_selection.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String packageId;
  const CheckoutScreen({super.key, required this.packageId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _planIndex = 2;
  final Set<String> _selectedAddOns = {};

  @override
  Widget build(BuildContext context) {
    final packageAsync = ref.watch(packageDetailProvider(widget.packageId));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Checkout'),
      ),
      body: AsyncValueView(
        value: packageAsync,
        builder: (package) => _buildBody(context, package),
      ),
    );
  }

  Widget _buildBody(BuildContext context, InsurancePackage package) {
    final plans = MockData.planOptionsFor(package);
    final plan = plans[_planIndex];
    final addOns = MockData.addOns.where((a) => _selectedAddOns.contains(a.id)).toList();
    final selection = CheckoutSelection(package: package, plan: plan, addOns: addOns);

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
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.sm)),
                        child: Icon(package.category.icon, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(package.name, style: Theme.of(context).textTheme.titleSmall),
                            Text('${AppFormatters.currencyWhole(package.coverageAmount)} coverage', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Choose your plan', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              for (var i = 0; i < plans.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PlanOptionTile(
                    plan: plans[i],
                    selected: _planIndex == i,
                    onTap: () => setState(() => _planIndex = i),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text('Optional add-ons', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              for (final addOn in MockData.addOns)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AddOnTile(
                    addOn: addOn,
                    selected: _selectedAddOns.contains(addOn.id),
                    onChanged: (v) => setState(() => v ? _selectedAddOns.add(addOn.id) : _selectedAddOns.remove(addOn.id)),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                color: AppColors.primary.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _summaryRow(context, '${plan.label} plan', AppFormatters.currency(plan.totalPrice)),
                      if (addOns.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        for (final a in addOns) _summaryRow(context, a.name, AppFormatters.currency(a.price * plan.months)),
                      ],
                      const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.sm), child: Divider()),
                      _summaryRow(context, 'Total due', AppFormatters.currency(selection.total), emphasize: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: PrimaryButton(
              label: 'Continue to payment · ${AppFormatters.currency(selection.total)}',
              onPressed: () => context.push('/checkout/payment-method', extra: selection),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value, {bool emphasize = false}) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

class _PlanOptionTile extends StatelessWidget {
  final PackagePlanOption plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanOptionTile({required this.plan, required this.selected, required this.onTap});

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
            Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? AppColors.primary : Theme.of(context).disabledColor),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Row(
                children: [
                  Text(plan.label, style: Theme.of(context).textTheme.titleSmall),
                  if (plan.badge != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(AppRadius.pill)),
                      child: Text(plan.badge!, style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            ),
            Text(AppFormatters.currency(plan.totalPrice), style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

class _AddOnTile extends StatelessWidget {
  final PackageAddOn addOn;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _AddOnTile({required this.addOn, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => onChanged(!selected),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? AppColors.primary : Theme.of(context).dividerColor, width: selected ? 1.6 : 1),
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(addOn.name, style: Theme.of(context).textTheme.titleSmall),
                  Text(addOn.description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Text('+${AppFormatters.currency(addOn.price)}/mo', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: AppSpacing.sm),
            Switch(value: selected, onChanged: onChanged, activeThumbColor: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
