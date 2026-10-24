import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/claim.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/status_badge.dart';

class ClaimDetailScreen extends ConsumerWidget {
  final String claimId;
  const ClaimDetailScreen({super.key, required this.claimId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final claimAsync = ref.watch(claimDetailProvider(claimId));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.tr('claim.title')),
        actions: [
          IconButton(
            tooltip: l10n.tr('claim.contactSupport'),
            onPressed: () => _showDocumentSheet(context, claimAsync.value),
            icon: const Icon(Icons.support_agent_rounded),
          ),
        ],
      ),
      body: AsyncValueView(
        value: claimAsync,
        onRetry: () => ref.invalidate(claimDetailProvider(claimId)),
        builder: (claim) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(claimDetailProvider(claimId)),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              _ClaimHero(claim: claim),
              const SizedBox(height: AppSpacing.md),
              _NextStepCard(claim: claim),
              const SizedBox(height: AppSpacing.md),
              _TimelineCard(claim: claim),
              if (claim.hasDecision ||
                  (claim.reviewNotes?.isNotEmpty ?? false)) ...[
                const SizedBox(height: AppSpacing.md),
                _DecisionCard(claim: claim),
              ],
              const SizedBox(height: AppSpacing.md),
              _DetailsCard(claim: claim),
              const SizedBox(height: AppSpacing.lg),
              _DocumentButton(claim: claim),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => context.push('/my-policies/${claim.policyId}'),
                icon: const Icon(Icons.shield_outlined, size: 18),
                label: Text(l10n.tr('claim.viewPolicy')),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SupportBanner(claim: claim),
            ],
          ),
        ),
      ),
    );
  }
}

double _progressFor(ClaimStatus status) {
  switch (status) {
    case ClaimStatus.submitted:
      return 0.35;
    case ClaimStatus.underReview:
      return 0.8;
    case ClaimStatus.approved:
    case ClaimStatus.rejected:
      return 1;
  }
}

Color _statusColor(ClaimStatus status) {
  switch (status) {
    case ClaimStatus.approved:
      return AppColors.success;
    case ClaimStatus.rejected:
      return AppColors.error;
    case ClaimStatus.underReview:
      return AppColors.warning;
    case ClaimStatus.submitted:
      return AppColors.primary;
  }
}

List<Color> _heroGradient(ClaimStatus status) {
  switch (status) {
    case ClaimStatus.approved:
      return const [Color(0xFF25C08F), Color(0xFF0C9A6A)];
    case ClaimStatus.rejected:
      return const [Color(0xFFF08077), Color(0xFFC8484F)];
    default:
      return AppColors.heroGradient;
  }
}

String _heroTitle(AppLocalizations l10n, Claim claim) {
  switch (claim.status) {
    case ClaimStatus.submitted:
    case ClaimStatus.underReview:
      return l10n.tr('claim.inProgress');
    case ClaimStatus.approved:
      return l10n.tr('claim.approvedTitle');
    case ClaimStatus.rejected:
      return l10n.tr('claim.rejectedTitle');
  }
}

IconData _heroIcon(ClaimStatus status) {
  switch (status) {
    case ClaimStatus.approved:
      return Icons.task_alt_rounded;
    case ClaimStatus.rejected:
      return Icons.info_outline_rounded;
    case ClaimStatus.underReview:
      return Icons.manage_search_rounded;
    case ClaimStatus.submitted:
      return Icons.hourglass_top_rounded;
  }
}

class _ClaimHero extends StatelessWidget {
  final Claim claim;

  const _ClaimHero({required this.claim});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = _progressFor(claim.status);
    final percent = (progress * 100).round();
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl + 2),
        gradient: LinearGradient(
          colors: _heroGradient(claim.status),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _heroGradient(claim.status).last.withValues(alpha: 0.26),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            top: -44,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 20,
                ),
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 18,
            child: Icon(
              Icons.shield_outlined,
              size: 62,
              color: Colors.white.withValues(alpha: 0.09),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        _heroIcon(claim.status),
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _heroTitle(l10n, claim),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            claim.claimNumber,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        l10n.claimStatus(claim.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  claim.policyName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  AppFormatters.currency(claim.amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                Text(
                  l10n.tr('claim.claimedAmount'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.tr('claim.progress'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
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

class _NextStepCard extends StatelessWidget {
  final Claim claim;
  const _NextStepCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = _statusColor(claim.status);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  switch (claim.status) {
                    ClaimStatus.approved => Icons.task_alt_rounded,
                    ClaimStatus.rejected => Icons.info_outline_rounded,
                    ClaimStatus.underReview => Icons.manage_search_rounded,
                    ClaimStatus.submitted => Icons.schedule_rounded,
                  },
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.tr('claim.nextStep'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontSize: 12.5,
                  ),
                ),
              ),
              StatusBadge(label: l10n.claimStatus(claim.status), color: color),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            l10n.claimNextStepTitle(claim.status),
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 14.5),
          ),
          const SizedBox(height: 3),
          Text(
            l10n.claimNextStepBody(claim.status),
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.55,
              fontSize: 12.5,
            ),
          ),
          if (claim.status == ClaimStatus.rejected) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.support_agent_rounded, size: 15, color: color),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    l10n.tr('claim.supportLine'),
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm + 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.notifications_active_outlined,
                size: 14,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  l10n.tr('claim.inAppUpdates'),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Claim claim;
  const _TimelineCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final reviewed = claim.status != ClaimStatus.submitted;
    final decided = claim.hasDecision;
    final decisionColor = _statusColor(claim.status);

    final steps = <_TimelineStep>[
      _TimelineStep(
        title: l10n.tr('claim.stepSubmitted'),
        subtitle: l10n.tr('claim.stepSubmittedSubtitle', {
          'date': l10n.formatDate(claim.submittedAt),
        }),
        state: _StepState.done,
      ),
      _TimelineStep(
        title: l10n.tr('claim.stepReview'),
        subtitle: reviewed
            ? (decided
                  ? l10n.tr('claim.stepReviewDone')
                  : l10n.tr('claim.stepReviewActive'))
            : l10n.tr('claim.stepReviewPending'),
        state: reviewed ? _StepState.done : _StepState.active,
      ),
      _TimelineStep(
        title: decided
            ? l10n.claimStatus(claim.status)
            : l10n.tr('claim.stepDecision'),
        subtitle: claim.reviewedAt != null
            ? l10n.tr('claim.stepDecisionUpdated', {
                'date': l10n.formatDate(claim.reviewedAt!),
              })
            : l10n.tr('claim.stepDecisionPending'),
        state: decided ? _StepState.done : _StepState.pending,
        color: decided ? decisionColor : null,
        icon: claim.status == ClaimStatus.rejected ? Icons.close_rounded : null,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timeline_rounded,
                size: 19,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.tr('claim.timeline'),
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 14.5),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < steps.length; i++)
            _TimelineRow(
              step: steps[i],
              isLast: i == steps.length - 1,
              previousDone: i == 0 || steps[i - 1].state == _StepState.done,
            ),
        ],
      ),
    );
  }
}

enum _StepState { done, active, pending }

class _TimelineStep {
  final String title;
  final String subtitle;
  final _StepState state;
  final Color? color;
  final IconData? icon;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.state,
    this.color,
    this.icon,
  });
}

class _TimelineRow extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;
  final bool previousDone;

  const _TimelineRow({
    required this.step,
    required this.isLast,
    required this.previousDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = step.state == _StepState.done;
    final active = step.state == _StepState.active;
    final color = done
        ? (step.color ?? AppColors.success)
        : active
        ? AppColors.primary
        : theme.disabledColor;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 31,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: done || active ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: done || active ? color : theme.dividerColor,
                      width: 1.6,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.28),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    done
                        ? (step.icon ?? Icons.check_rounded)
                        : active
                        ? Icons.more_horiz_rounded
                        : Icons.circle,
                    size: done || active ? 15 : 6,
                    color: done || active ? Colors.white : theme.disabledColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: done
                          ? color.withValues(alpha: 0.45)
                          : previousDone
                          ? color.withValues(alpha: 0.25)
                          : theme.dividerColor.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacing.lg,
                top: 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 13,
                            color: done || active
                                ? null
                                : theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                      if (active)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            context.l10n.tr('claim.current'),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  final Claim claim;
  const _DecisionCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hasNote = claim.reviewNotes != null && claim.reviewNotes!.isNotEmpty;
    final color = _statusColor(claim.status);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.gavel_rounded,
                size: 19,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.tr('claim.decisionNotes'),
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 14.5),
                ),
              ),
              StatusBadge(label: l10n.claimStatus(claim.status), color: color),
            ],
          ),
          if (claim.reviewedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.tr('claim.reviewedOn', {
                'date': l10n.formatDate(claim.reviewedAt!),
              }),
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasNote ? l10n.tr('claim.teamNote') : l10n.tr('claim.noNote'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasNote ? claim.reviewNotes! : l10n.tr('claim.noNoteBody'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          if (claim.status == ClaimStatus.rejected) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.tr('claim.appeal', {'number': claim.claimNumber}),
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.45,
                fontSize: 11.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final Claim claim;
  const _DetailsCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 19,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.tr('claim.details'),
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 14.5),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            label: l10n.tr('claim.claimNumber'),
            value: claim.claimNumber,
          ),
          _DetailRow(
            label: l10n.tr('claim.type'),
            value: l10n.claimType(claim.type),
          ),
          _DetailRow(
            label: l10n.tr('claim.incidentDate'),
            value: l10n.formatDate(claim.incidentDate),
          ),
          _DetailRow(
            label: l10n.tr('claim.submittedOn'),
            value: l10n.formatDate(claim.submittedAt),
            last: true,
          ),
          const Divider(height: AppSpacing.lg),
          Text(
            l10n.tr('claim.reported'),
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            claim.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.55,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool last;

  const _DetailRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall?.copyWith(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentButton extends StatelessWidget {
  final Claim claim;
  const _DocumentButton({required this.claim});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          gradient: const LinearGradient(
            colors: AppColors.tileGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: () => _showDocumentSheet(context, claim),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: AppSpacing.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.upload_file_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.tr('claim.addDocuments'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportBanner extends StatelessWidget {
  final Claim claim;
  const _SupportBanner({required this.claim});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.softGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tr('claim.needHelp'),
                  style: theme.textTheme.titleSmall?.copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.tr('claim.needHelpBody'),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showDocumentSheet(context, claim),
            child: Text(l10n.tr('claim.contactSupport')),
          ),
        ],
      ),
    );
  }
}

void _showDocumentSheet(BuildContext context, Claim? claim) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.tr('claim.addDocumentsTitle'),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.tr('claim.addDocumentsBody', {
                  'number': claim?.claimNumber ?? '',
                }),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.055),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  l10n.tr('claim.supportLine'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(
                        text: 'Insurancehelpcenter12@gmail.com',
                      ),
                    );
                    if (sheetContext.mounted) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        SnackBar(content: Text(l10n.tr('common.copied'))),
                      );
                    }
                  },
                  icon: const Icon(Icons.mail_outline_rounded, size: 18),
                  label: Text(l10n.tr('claim.copyEmail')),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
