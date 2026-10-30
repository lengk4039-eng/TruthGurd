import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/policy.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/formatters.dart';
import 'category_image.dart';
import 'glass/glass_card.dart';
import 'status_badge.dart';

class PolicyCard extends StatelessWidget {
  final Policy policy;
  final VoidCallback onTap;

  const PolicyCard({super.key, required this.policy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = GlassInk.muted(context, GlassTone.light);
    final brand = AppColors.brandOn(
      onDark: GlassInk.surfaceIsDark(context, GlassTone.light),
    );
    final statusColor = switch (policy.status) {
      PolicyStatus.active => AppColors.success,
      PolicyStatus.pending => AppColors.warning,
      PolicyStatus.expired || PolicyStatus.cancelled => AppColors.error,
    };
    return GlassCard(
      tone: GlassTone.light,
      blur: AppBlur.medium,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      onTap: onTap,
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
              backgroundColor: brand.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(brand),
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
    );
  }
}
