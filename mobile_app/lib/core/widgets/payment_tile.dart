import 'package:flutter/material.dart';

import '../models/payment.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/formatters.dart';
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
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final color = AppColors.forStatus(payment.status.label);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(_icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.policyName, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      payment.status == PaymentStatus.paid
                          ? 'Paid ${AppFormatters.date(payment.paidDate!)}'
                          : '${AppFormatters.daysUntil(payment.dueDate)} · ${AppFormatters.date(payment.dueDate)}',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppFormatters.currency(payment.amount), style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  StatusBadge(label: payment.status.label),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
