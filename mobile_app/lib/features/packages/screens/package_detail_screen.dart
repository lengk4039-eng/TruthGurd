import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/insurance_package.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/category_image.dart';
import '../../../core/widgets/primary_button.dart';

class PackageDetailScreen extends ConsumerWidget {
  final String packageId;
  const PackageDetailScreen({super.key, required this.packageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageAsync = ref.watch(packageDetailProvider(packageId));

    return Scaffold(
      body: AsyncValueView(
        value: packageAsync,
        builder: (package) => _PackageDetailBody(package: package),
      ),
    );
  }
}

class _PackageDetailBody extends StatelessWidget {
  final InsurancePackage package;
  const _PackageDetailBody({required this.package});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 240,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.white),
                leading: const AppBackButton(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white24,
                  padding: EdgeInsets.only(left: 12),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.tileGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      80,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CategoryImage(
                          category: package.category,
                          size: 56,
                          radius: AppRadius.sm,
                          borderColor: Colors.white.withValues(alpha: 0.65),
                          borderWidth: 2,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          package.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          package.tagline,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        _StatChip(
                          label: l10n.tr('packages.coverage'),
                          value: AppFormatters.currencyWhole(
                            package.coverageAmount,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatChip(
                          label: l10n.tr('packages.from'),
                          value:
                              '${AppFormatters.currencyWhole(package.monthlyPrice)}${l10n.tr('packages.perMonth')}',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatChip(
                          label: l10n.tr('packages.rating'),
                          value: '★ ${package.rating}',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l10n.tr('packages.about'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      package.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l10n.tr('packages.whatCovered'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final benefit in package.benefits)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                benefit,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (package.reviewCount > 0) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.tr('packages.ratedFrom', {
                          'rating': '${package.rating}',
                          'count': '${package.reviewCount}',
                        }),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    _ClaimsLegalSection(package: package),
                    const SizedBox(height: AppSpacing.xl),
                  ]),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tr('packages.startingAt'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${AppFormatters.currency(package.monthlyPrice)}${l10n.tr('packages.perMonth')}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PrimaryButton(
                        label: l10n.tr('packages.buyNow'),
                        onPressed: () =>
                            context.push('/packages/${package.id}/checkout'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push('/packages/${package.id}/quote'),
                    icon: const Icon(Icons.request_quote_outlined),
                    label: Text(l10n.tr('packages.getQuote')),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ClaimsLegalSection extends StatelessWidget {
  final InsurancePackage package;
  const _ClaimsLegalSection({required this.package});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final documents = package.claimDocuments.isEmpty
        ? [
            l10n.tr('packages.defaultDocProof'),
            l10n.tr('packages.defaultDocInvoices'),
            l10n.tr('packages.defaultDocId'),
          ]
        : package.claimDocuments;
    final exclusions = package.exclusions.isEmpty
        ? [
            l10n.tr('packages.defaultExclusionOutside'),
            l10n.tr('packages.defaultExclusionFraud'),
          ]
        : package.exclusions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.tr('packages.claimsLegal'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatChip(
                      label: l10n.tr('packages.waitingPeriod'),
                      value: l10n.tr('packages.days', {
                        'count': '${package.waitingPeriodDays}',
                      }),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatChip(
                      label: l10n.tr('packages.fileWithin'),
                      value: l10n.tr('packages.days', {
                        'count': '${package.claimWindowDays}',
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.tr('packages.howAssessed'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  package.claimPolicy.isEmpty
                      ? l10n.tr('packages.defaultAssess')
                      : package.claimPolicy,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: muted, height: 1.55),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.tr('packages.documents'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                _LegalList(
                  items: documents,
                  icon: Icons.description_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.tr('packages.notCovered'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                _LegalList(
                  items: exclusions,
                  icon: Icons.close_rounded,
                  color: AppColors.error,
                ),
                if (package.legalTerms.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Divider(),
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      leading: const Icon(
                        Icons.gavel_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      title: Text(
                        l10n.tr('packages.fullTerms'),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        l10n.tr('packages.fullTermsSubtitle'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      children: [
                        Text(
                          package.legalTerms,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(height: 1.55),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.tr('packages.legalNote'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LegalList extends StatelessWidget {
  final List<String> items;
  final IconData icon;
  final Color color;

  const _LegalList({
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: muted, height: 1.45, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
