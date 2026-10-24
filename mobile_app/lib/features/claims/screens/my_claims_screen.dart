import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/claim.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';

class MyClaimsScreen extends ConsumerWidget {
  const MyClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(myClaimsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('My claims'),
      ),
      body: AsyncValueView(
        value: claimsAsync,
        onRetry: () => ref.invalidate(myClaimsProvider),
        builder: (claims) {
          if (claims.isEmpty) {
            return EmptyState(
              icon: Icons.assignment_outlined,
              title: 'No claims yet',
              message: 'If something happens, open an active policy and file a claim from there.',
              actionLabel: 'My policies',
              onAction: () => context.go('/my-policies'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myClaimsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
              itemCount: claims.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      'Tap a claim to see its progress, decision and next steps.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                final claim = claims[index - 1];
                return _ClaimCard(
                  claim: claim,
                  onTap: () => context.push('/claims/${claim.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ClaimCard extends StatelessWidget {
  final Claim claim;
  final VoidCallback onTap;

  const _ClaimCard({required this.claim, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final accent = switch (claim.status) {
      ClaimStatus.approved => AppColors.success,
      ClaimStatus.rejected => AppColors.error,
      _ => AppColors.primary,
    };
    final statusIcon = switch (claim.status) {
      ClaimStatus.submitted => Icons.schedule_rounded,
      ClaimStatus.underReview => Icons.manage_search_rounded,
      ClaimStatus.approved => Icons.task_alt_rounded,
      ClaimStatus.rejected => Icons.info_outline_rounded,
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(statusIcon, color: accent, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(claim.policyName, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          '${claim.claimNumber} · ${claim.type.label}',
                          style: TextStyle(color: muted, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(label: claim.status.label),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Text(
                    AppFormatters.currency(claim.amount),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    claim.reviewedAt != null
                        ? 'Updated ${AppFormatters.date(claim.reviewedAt!)}'
                        : 'Submitted ${AppFormatters.date(claim.submittedAt)}',
                    style: TextStyle(color: muted, fontSize: 11.5),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 18, color: muted),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.subdirectory_arrow_right_rounded, size: 15, color: accent),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        claim.nextStep,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5, height: 1.4, color: muted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
