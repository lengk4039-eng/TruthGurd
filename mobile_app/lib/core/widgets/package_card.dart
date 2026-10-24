import 'package:flutter/material.dart';

import '../models/insurance_category.dart';
import '../models/insurance_package.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/formatters.dart';

/// Represents one [InsurancePackage]. [featured] switches between the
/// compact list-row style (Packages tab) and the wide gradient hero style
/// (Home's "Featured for you" rail).
class PackageCard extends StatelessWidget {
  final InsurancePackage package;
  final bool featured;
  final VoidCallback onTap;

  const PackageCard({super.key, required this.package, required this.onTap, this.featured = false});

  @override
  Widget build(BuildContext context) {
    return featured ? _buildFeatured(context) : _buildListRow(context);
  }

  Widget _buildFeatured(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: const LinearGradient(colors: AppColors.tileGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.28), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(package.category.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              package.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, height: 1.25),
            ),
            const SizedBox(height: 4),
            Text(
              package.tagline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5, height: 1.3),
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  '${AppFormatters.currencyWhole(package.monthlyPrice)}/mo',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: const Icon(Icons.arrow_forward_rounded, size: 15, color: AppColors.primaryDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListRow(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Icon(package.category.icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(package.name, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                        ),
                        if (package.isFeatured)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.pill)),
                            child: const Text('Popular', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(package.tagline, style: TextStyle(color: muted, fontSize: 12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.currencyWhole(package.monthlyPrice),
                    style: const TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  Text('/mo', style: TextStyle(color: muted, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
