import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/claim.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/widgets/glass/glass_page_scaffold.dart';
import '../../../core/widgets/status_badge.dart';

class MyClaimsScreen extends ConsumerWidget {
  const MyClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(myClaimsProvider);
    final l10n = context.l10n;

    return GlassPageScaffold(
      title: l10n.tr('claims.title'),
      child: AsyncValueView(
        value: claimsAsync,
        onRetry: () => ref.invalidate(myClaimsProvider),
        builder: (claims) {
          if (claims.isEmpty) {
            return EmptyState(
              icon: Icons.assignment_outlined,
              title: l10n.tr('claims.emptyTitle'),
              message: l10n.tr('claims.emptyBody'),
              actionLabel: l10n.tr('claims.action'),
              onAction: () => context.go('/my-policies'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myClaimsProvider),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: claims.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      l10n.tr('claims.hint'),
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
    final l10n = context.l10n;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final accent = switch (claim.status) {
      ClaimStatus.submitted => AppColors.warning,
      ClaimStatus.underReview => AppColors.primary,
      ClaimStatus.approved => AppColors.success,
      ClaimStatus.rejected => AppColors.error,
    };
    final statusIcon = switch (claim.status) {
      ClaimStatus.submitted => Icons.schedule_rounded,
      ClaimStatus.underReview => Icons.manage_search_rounded,
      ClaimStatus.approved => Icons.task_alt_rounded,
      ClaimStatus.rejected => Icons.info_outline_rounded,
    };
    // The hue is also painted as small glyphs on pale glass, where raw
    // `primary` sits under 3:1.
    final accentInk = AppColors.legibleHue(
      accent,
      onDark: GlassInk.surfaceIsDark(context, GlassTone.light),
    );

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(statusIcon, color: accentInk, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.policyName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${claim.claimNumber} · ${l10n.claimType(claim.type)}',
                      style: TextStyle(color: muted, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(label: l10n.claimStatus(claim.status), color: accent),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                AppFormatters.currency(claim.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                claim.reviewedAt != null
                    ? l10n.tr('claims.updatedOn', {
                        'date': l10n.formatDate(claim.reviewedAt!),
                      })
                    : l10n.tr('claims.submittedOn', {
                        'date': l10n.formatDate(claim.submittedAt),
                      }),
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
                Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  size: 15,
                  color: accentInk,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    l10n.claimNextStepBody(claim.status),
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
    );
  }
}
