import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/payment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/formatters.dart';
import 'glass_card.dart';
import 'glass_icon.dart';

/// Component C — the upcoming-payments summary.
///
/// The outer panel is real glass; the rows inside it are translucent rather
/// than blurred. A [BackdropFilter] per row would stack five blur passes
/// inside one card and cost frame budget for no visible depth.
class UpcomingPaymentsCard extends StatelessWidget {
  final List<Payment> payments;
  final ValueChanged<Payment> onTapPayment;
  final VoidCallback? onSeeAll;

  const UpcomingPaymentsCard({
    super.key,
    required this.payments,
    required this.onTapPayment,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return GlassCard(
      tone: GlassTone.light,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      blur: AppBlur.medium,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 0, AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.tr('home.upcomingPayments'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: GlassInk.primary(context, GlassTone.light),
                    ),
                  ),
                ),
                if (onSeeAll != null)
                  TextButton(
                    onPressed: onSeeAll,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(l10n.tr('common.seeAll')),
                  ),
              ],
            ),
          ),
          for (var i = 0; i < payments.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            _PaymentRow(
              payment: payments[i],
              onTap: () => onTapPayment(payments[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;

  const _PaymentRow({required this.payment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final overdue = payment.dueDate.isBefore(DateTime.now());
    final onDark = GlassInk.surfaceIsDark(context, GlassTone.light);

    return Material(
      color: Colors.white.withValues(alpha: onDark ? 0.07 : 0.55),
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
            border: Border.all(
              color: onDark ? AppColors.hairlineDark : AppColors.hairlineLight,
            ),
            boxShadow: AppShadow.shadow(isDark: onDark),
          ),
          child: Row(
            children: [
              GlassIcon(kind: GlassIconKind.receipt, size: 40),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.policyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: GlassInk.primary(context, GlassTone.light),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payment.invoiceNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: GlassInk.muted(context, GlassTone.light),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.currency(payment.amount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: GlassInk.primary(context, GlassTone.light),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (overdue ? AppColors.error : AppColors.warning)
                          .withValues(alpha: 0.16),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadius.pill),
                      ),
                    ),
                    child: Text(
                      AppFormatters.dateShort(payment.dueDate),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: overdue ? AppColors.error : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
