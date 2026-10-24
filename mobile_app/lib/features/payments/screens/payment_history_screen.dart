import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/payment.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/payment_tile.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  PaymentStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final paymentsAsync = ref.watch(myPaymentsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('payment.title'))),
      body: SafeArea(
        top: false,
        child: AsyncValueView(
          value: paymentsAsync,
          onRetry: () => ref.invalidate(myPaymentsProvider),
          builder: (payments) {
            final filtered = _filter == null
                ? payments
                : payments.where((p) => p.status == _filter).toList();
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(myPaymentsProvider),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: [
                  _MonthlySpendChart(payments: payments),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FilterChip(
                          label: l10n.tr('payment.filterAll'),
                          selected: _filter == null,
                          onTap: () => setState(() => _filter = null),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: l10n.tr('payment.filterPaid'),
                          selected: _filter == PaymentStatus.paid,
                          onTap: () =>
                              setState(() => _filter = PaymentStatus.paid),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: l10n.tr('payment.filterPending'),
                          selected: _filter == PaymentStatus.pending,
                          onTap: () =>
                              setState(() => _filter = PaymentStatus.pending),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: l10n.tr('payment.filterOverdue'),
                          selected: _filter == PaymentStatus.overdue,
                          onTap: () =>
                              setState(() => _filter = PaymentStatus.overdue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (filtered.isEmpty)
                    EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: l10n.tr('payment.noPaymentsTitle'),
                      message: l10n.tr('payment.noPaymentsBody'),
                    )
                  else
                    Column(
                      children: [
                        for (final payment in filtered) ...[
                          PaymentTile(
                            payment: payment,
                            onTap: () =>
                                context.push('/payments/${payment.id}'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MonthlySpendChart extends StatelessWidget {
  final List<Payment> payments;
  const _MonthlySpendChart({required this.payments});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(
      6,
      (i) => DateTime(now.year, now.month - (5 - i)),
    );
    final totals = months.map((m) {
      return payments
          .where(
            (p) =>
                p.status == PaymentStatus.paid &&
                p.paidDate != null &&
                p.paidDate!.year == m.year &&
                p.paidDate!.month == m.month,
          )
          .fold<double>(0, (sum, p) => sum + p.amount);
    }).toList();
    final maxTotal = totals.fold<double>(0, (m, v) => v > m ? v : m);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.tr('payment.spendChart'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 130,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxTotal <= 0 ? 100 : maxTotal * 1.35,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            context.l10n.monthAbbr(months[i]),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(enabled: false),
                barGroups: [
                  for (var i = 0; i < totals.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: totals[i] <= 0 ? 0.001 : totals[i],
                          width: 20,
                          borderRadius: BorderRadius.circular(6),
                          color: i == totals.length - 1
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
