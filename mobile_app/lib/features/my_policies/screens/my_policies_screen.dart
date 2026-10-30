import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/policy.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass/glass_filter_chip.dart';
import '../../../core/widgets/glass/glass_page_header.dart';
import '../../../core/widgets/policy_card.dart';

class MyPoliciesScreen extends ConsumerStatefulWidget {
  const MyPoliciesScreen({super.key});

  @override
  ConsumerState<MyPoliciesScreen> createState() => _MyPoliciesScreenState();
}

class _MyPoliciesScreenState extends ConsumerState<MyPoliciesScreen> {
  PolicyStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final policiesAsync = ref.watch(myPoliciesProvider);
    final l10n = context.l10n;
    final filters = <PolicyStatus?>[
      null,
      PolicyStatus.active,
      PolicyStatus.pending,
      PolicyStatus.expired,
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(myPoliciesProvider),
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
                  child: GlassPageHeader(
                    title: l10n.tr('policies.title'),
                    actions: [
                      GlassIconButton(
                        icon: Icons.add_rounded,
                        tooltip: l10n.tr('policies.buyNew'),
                        onTap: () => context.go('/packages'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: GlassFilterBar(
                    labels: [
                      l10n.tr('policies.all'),
                      l10n.policyStatus(PolicyStatus.active),
                      l10n.policyStatus(PolicyStatus.pending),
                      l10n.policyStatus(PolicyStatus.expired),
                    ],
                    selectedIndex: filters.indexOf(_filter),
                    onSelect: (i) => setState(() => _filter = filters[i]),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  108,
                ),
                sliver: AsyncValueView(
                  value: policiesAsync,
                  onRetry: () => ref.invalidate(myPoliciesProvider),
                  sliverBuilder: (policies) {
                    final filtered = _filter == null
                        ? policies
                        : policies.where((p) => p.status == _filter).toList();
                    if (filtered.isEmpty) {
                      return SliverToBoxAdapter(
                        child: EmptyState(
                          icon: Icons.shield_outlined,
                          title: l10n.tr('policies.emptyTitle'),
                          message: l10n.tr('policies.emptyBody'),
                          actionLabel: l10n.tr('policies.browse'),
                          onAction: () => context.go('/packages'),
                        ),
                      );
                    }
                    return SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) => PolicyCard(
                        policy: filtered[i],
                        onTap: () =>
                            context.push('/my-policies/${filtered[i].id}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
