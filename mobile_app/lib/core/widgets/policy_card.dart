import 'package:flutter/material.dart';

import '../models/insurance_category.dart';
import '../models/policy.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/formatters.dart';
import 'status_badge.dart';

class PolicyCard extends StatelessWidget {
  final Policy policy;
  final VoidCallback onTap;

  const PolicyCard({super.key, required this.policy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: Icon(policy.package.category.icon, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(policy.package.name, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                        Text(policy.policyNumber, style: TextStyle(color: muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  StatusBadge(label: policy.status.label),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: policy.paidProgress,
                  minHeight: 6,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppFormatters.currencyWhole(policy.amountPaid)} of ${AppFormatters.currencyWhole(policy.totalPremium)} paid',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  if (policy.nextPaymentDate != null)
                    Text(
                      AppFormatters.daysUntil(policy.nextPaymentDate!),
                      style: TextStyle(
                        color: policy.nextPaymentDate!.isBefore(DateTime.now()) ? AppColors.error : muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
