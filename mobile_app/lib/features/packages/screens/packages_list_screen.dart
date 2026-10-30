import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/insurance_category.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/widgets/glass/glass_filter_chip.dart';
import '../../../core/widgets/glass/glass_page_header.dart';
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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: Column(
                  children: [
                    GlassPageHeader(title: l10n.tr('packages.title')),
                    _GlassSearchField(
                      hint: l10n.tr('packages.searchHint'),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        padding: EdgeInsets.zero,
                        itemCount: InsuranceCategoryType.values.length + 1,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, i) {
                          if (i == 0) {
                            return GlassFilterChip(
                              label: l10n.tr('packages.all'),
                              icon: Icons.apps_rounded,
                              selected: _selected == null,
                              onTap: () => setState(() => _selected = null),
                            );
                          }
                          final category = InsuranceCategoryType.values[i - 1];
                          return GlassFilterChip(
                            label: l10n.category(category),
                            icon: category.icon,
                            selected: _selected == category,
                            onTap: () => setState(() => _selected = category),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                108,
              ),
              sliver: AsyncValueView(
                value: packagesAsync,
                onRetry: () => ref.invalidate(packagesListProvider(_selected)),
                sliverBuilder: (packages) {
                  final query = _query.trim().toLowerCase();
                  final filtered = query.isEmpty
                      ? packages
                      : packages
                            .where(
                              (p) =>
                                  p.name.toLowerCase().contains(query) ||
                                  p.tagline.toLowerCase().contains(query),
                            )
                            .toList();
                  if (filtered.isEmpty) {
                    return SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.search_off_rounded,
                        title: l10n.tr('packages.emptyTitle'),
                        message: l10n.tr('packages.emptyBody'),
                      ),
                    );
                  }
                  return SliverList.separated(
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

/// The search box is glass rather than a filled field, so it reads as part of
/// the backdrop instead of a form control pasted on top of it.
class _GlassSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _GlassSearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ink = GlassInk.primary(context, GlassTone.light);
    final muted = GlassInk.muted(context, GlassTone.light);
    return GlassCard(
      tone: GlassTone.light,
      blur: AppBlur.soft,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 20, color: muted),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                style: TextStyle(color: ink, fontSize: 14),
                cursorColor: ink,
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  hintText: hint,
                  hintStyle: TextStyle(color: muted, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
