import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/insurance_package.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/formatters.dart';
import 'category_image.dart';
import 'glass/glass_card.dart';

/// A package row on the Packages tab. Home's "Featured for you" rail uses
/// [FeatureCardCarousel] instead, which is a wider photo-led card.
class PackageCard extends StatelessWidget {
  final InsurancePackage package;
  final VoidCallback onTap;

  const PackageCard({super.key, required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onDark = GlassInk.surfaceIsDark(context, GlassTone.light);
    final muted = GlassInk.muted(context, GlassTone.light);
    final brand = AppColors.brandOn(onDark: onDark);
    return GlassCard(
      tone: GlassTone.light,
      blur: AppBlur.medium,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      onTap: onTap,
      child: Row(
        children: [
          CategoryImage(
            category: package.category,
            size: 52,
            radius: AppRadius.md,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        package.name,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (package.isFeatured)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          l10n.tr('packages.popular'),
                          style: TextStyle(
                            color: AppColors.legibleHue(
                              AppColors.accent,
                              onDark: onDark,
                            ),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  package.tagline,
                  style: TextStyle(color: muted, fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.currencyWhole(package.monthlyPrice),
                style: TextStyle(
                  color: brand,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.tr('packages.perMonth'),
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
