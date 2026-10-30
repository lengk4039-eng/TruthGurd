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
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/widgets/glass/glass_filter_chip.dart';
import '../../../core/widgets/glass/glass_page_header.dart';
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
    final filters = <PaymentStatus?>[
      null,
      PaymentStatus.paid,
      PaymentStatus.pending,
      PaymentStatus.overdue,
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(myPaymentsProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  108,
                ),
                sliver: AsyncValueView(
                  value: paymentsAsync,
                  onRetry: () => ref.invalidate(myPaymentsProvider),
                  sliverBuilder: (payments) {
                    final filtered = _filter == null
                        ? payments
                        : payments.where((p) => p.status == _filter).toList();
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        GlassPageHeader(title: l10n.tr('payment.title')),
                        _MonthlySpendChart(payments: payments),
                        const SizedBox(height: AppSpacing.lg),
                        GlassFilterBar(
                          labels: [
                            l10n.tr('payment.filterAll'),
                            l10n.tr('payment.filterPaid'),
                            l10n.tr('payment.filterPending'),
                            l10n.tr('payment.filterOverdue'),
                          ],
                          selectedIndex: filters.indexOf(_filter),
                          onSelect: (i) => setState(() => _filter = filters[i]),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (filtered.isEmpty)
                          EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: l10n.tr('payment.noPaymentsTitle'),
                            message: l10n.tr('payment.noPaymentsBody'),
                          )
                        else
                          for (final payment in filtered)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: PaymentTile(
                                payment: payment,
                                onTap: () =>
                                    context.push('/payments/${payment.id}'),
                              ),
                            ),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
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
    final l10n = context.l10n;
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
    final onDark = GlassInk.surfaceIsDark(context, GlassTone.light);
    final brand = AppColors.brandOn(onDark: onDark);
    final muted = GlassInk.muted(context, GlassTone.light);

    return GlassCard(
      tone: GlassTone.light,
      blur: AppBlur.medium,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tr('payment.spendChart'),
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
                            l10n.monthAbbr(months[i]),
                            style: TextStyle(fontSize: 10.5, color: muted),
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
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: i == totals.length - 1
                                ? [brand, AppColors.primary]
                                : [
                                    brand.withValues(alpha: 0.45),
                                    brand.withValues(alpha: 0.22),
                                  ],
                          ),
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
