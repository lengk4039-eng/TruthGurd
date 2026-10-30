import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/payment.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/formatters.dart';
import 'glass/glass_card.dart';
import 'status_badge.dart';

class PaymentTile extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;

  const PaymentTile({super.key, required this.payment, required this.onTap});

  IconData get _icon {
    switch (payment.status) {
      case PaymentStatus.paid:
        return Icons.check_circle_rounded;
      case PaymentStatus.pending:
        return Icons.schedule_rounded;
      case PaymentStatus.overdue:
        return Icons.error_rounded;
      case PaymentStatus.failed:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onDark = GlassInk.surfaceIsDark(context, GlassTone.light);
    final muted = GlassInk.muted(context, GlassTone.light);
    final statusColor = AppColors.forStatus(payment.status.label);
    return GlassCard(
      tone: GlassTone.light,
      blur: AppBlur.medium,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _icon,
              color: AppColors.legibleHue(statusColor, onDark: onDark),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.policyName,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  payment.status == PaymentStatus.paid
                      ? l10n.tr('policy.paidOn', {
                          'date': l10n.formatDate(payment.paidDate!),
                        })
                      : '${l10n.daysUntil(payment.dueDate)} · ${l10n.formatDate(payment.dueDate)}',
                  style: TextStyle(color: muted, fontSize: 12),
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
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              StatusBadge(
                label: l10n.paymentStatus(payment.status),
                color: statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
