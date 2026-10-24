import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/policy.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/formatters.dart';
import 'category_image.dart';
import 'status_badge.dart';

class PolicyCard extends StatelessWidget {
  final Policy policy;
  final VoidCallback onTap;

  const PolicyCard({super.key, required this.policy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final statusColor = switch (policy.status) {
      PolicyStatus.active => AppColors.success,
      PolicyStatus.pending => AppColors.warning,
      PolicyStatus.expired || PolicyStatus.cancelled => AppColors.error,
    };
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
                  CategoryImage(
                    category: policy.package.category,
                    size: 52,
                    radius: AppRadius.md,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policy.package.name,
                          style: Theme.of(context).textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          policy.policyNumber,
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: l10n.policyStatus(policy.status),
                    color: statusColor,
                  ),
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
                    l10n.tr('policies.paidOfTotal', {
                      'paid': AppFormatters.currencyWhole(policy.amountPaid),
                      'total': AppFormatters.currencyWhole(policy.totalPremium),
                    }),
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  if (policy.nextPaymentDate != null)
                    Text(
                      l10n.daysUntil(policy.nextPaymentDate!),
                      style: TextStyle(
                        color: policy.nextPaymentDate!.isBefore(DateTime.now())
                            ? AppColors.error
                            : muted,
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
