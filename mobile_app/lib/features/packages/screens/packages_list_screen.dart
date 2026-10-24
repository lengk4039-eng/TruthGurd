import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/insurance_category.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/category_filter_chip.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/package_card.dart';

class PackagesListScreen extends ConsumerStatefulWidget {
  const PackagesListScreen({super.key});

  @override
  ConsumerState<PackagesListScreen> createState() => _PackagesListScreenState();
}

class _PackagesListScreenState extends ConsumerState<PackagesListScreen> {
  InsuranceCategoryType? _selected;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final packagesAsync = ref.watch(packagesListProvider(_selected));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('packages.title'))),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: l10n.tr('packages.searchHint'),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: CategoryFilterChip(
                      label: l10n.tr('packages.all'),
                      icon: Icons.apps_rounded,
                      selected: _selected == null,
                      onTap: () => setState(() => _selected = null),
                    ),
                  ),
                  for (final category in InsuranceCategoryType.values)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: CategoryFilterChip(
                        label: l10n.category(category),
                        icon: category.icon,
                        selected: _selected == category,
                        onTap: () => setState(() => _selected = category),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: AsyncValueView(
                value: packagesAsync,
                builder: (packages) {
                  final filtered = _query.trim().isEmpty
                      ? packages
                      : packages
                            .where(
                              (p) =>
                                  p.name.toLowerCase().contains(
                                    _query.toLowerCase(),
                                  ) ||
                                  p.tagline.toLowerCase().contains(
                                    _query.toLowerCase(),
                                  ),
                            )
                            .toList();
                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: l10n.tr('packages.emptyTitle'),
                      message: l10n.tr('packages.emptyBody'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) => PackageCard(
                      package: filtered[i],
                      onTap: () => context.push('/packages/${filtered[i].id}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
