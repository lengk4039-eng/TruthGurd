import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/policy.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Policies'),
        actions: [
          IconButton(
            tooltip: 'Buy a new package',
            onPressed: () => context.go('/packages'),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                children: [
                  _FilterChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(label: 'Active', selected: _filter == PolicyStatus.active, onTap: () => setState(() => _filter = PolicyStatus.active)),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(label: 'Pending', selected: _filter == PolicyStatus.pending, onTap: () => setState(() => _filter = PolicyStatus.pending)),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(label: 'Expired', selected: _filter == PolicyStatus.expired, onTap: () => setState(() => _filter = PolicyStatus.expired)),
                ],
              ),
            ),
            Expanded(
              child: AsyncValueView(
                value: policiesAsync,
                onRetry: () => ref.invalidate(myPoliciesProvider),
                builder: (policies) {
                  final filtered = _filter == null ? policies : policies.where((p) => p.status == _filter).toList();
                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.shield_outlined,
                      title: 'Nothing here yet',
                      message: 'Policies matching this filter will show up here.',
                      actionLabel: 'Browse packages',
                      onAction: () => context.go('/packages'),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(myPoliciesProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) => PolicyCard(policy: filtered[i], onTap: () => context.push('/my-policies/${filtered[i].id}')),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : null, fontWeight: FontWeight.w600),
    );
  }
}
