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
import '../../../core/widgets/status_badge.dart';

class ClaimDetailScreen extends ConsumerWidget {
  final String claimId;
  const ClaimDetailScreen({super.key, required this.claimId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimAsync = ref.watch(claimDetailProvider(claimId));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Claim details'),
      ),
      body: AsyncValueView(
        value: claimAsync,
        onRetry: () => ref.invalidate(claimDetailProvider(claimId)),
        builder: (claim) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(claimDetailProvider(claimId)),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
            children: [
              _ClaimHero(claim: claim),
              const SizedBox(height: AppSpacing.lg),
              _NextStepCard(claim: claim),
              const SizedBox(height: AppSpacing.lg),
              _ProgressCard(claim: claim),
              if (claim.reviewNotes != null && claim.reviewNotes!.isNotEmpty || claim.hasDecision) ...[
                const SizedBox(height: AppSpacing.lg),
                _DecisionCard(claim: claim),
              ],
              const SizedBox(height: AppSpacing.lg),
              _DetailsCard(claim: claim),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/my-policies/${claim.policyId}'),
                  icon: const Icon(Icons.shield_outlined),
                  label: const Text('View related policy'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClaimHero extends StatelessWidget {
  final Claim claim;
  const _ClaimHero({required this.claim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: AppColors.tileGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.24), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  claim.claimNumber,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              StatusBadge(label: claim.status.label, subtle: false),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            claim.policyName,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontSize: 14, fontWeight: FontWeight.w500),
          ),
          if (claim.policyNumber != null) ...[
            const SizedBox(height: 2),
            Text(
              claim.policyNumber!,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppFormatters.currency(claim.amount),
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
          ),
          Text(
            'Claimed amount',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 12.5),
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
    final color = switch (claim.status) {
      ClaimStatus.approved => AppColors.success,
      ClaimStatus.rejected => AppColors.error,
      ClaimStatus.underReview => AppColors.warning,
      ClaimStatus.submitted => AppColors.primary,
    };
    final icon = switch (claim.status) {
      ClaimStatus.approved => Icons.task_alt_rounded,
      ClaimStatus.rejected => Icons.info_outline_rounded,
      ClaimStatus.underReview => Icons.manage_search_rounded,
      ClaimStatus.submitted => Icons.schedule_rounded,
    };
    final title = switch (claim.status) {
      ClaimStatus.approved => 'What happens next · Payout',
      ClaimStatus.rejected => 'What happens next · Appeal option',
      ClaimStatus.underReview => 'What happens next · Review in progress',
      ClaimStatus.submitted => 'What happens next · Queued for review',
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            claim.nextStep,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
          if (claim.status == ClaimStatus.rejected) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.support_agent_rounded, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Support: +855 87 908 470 · Insurancehelpcenter12@gmail.com',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You receive an in-app notification every time the status changes.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final Claim claim;
  const _ProgressCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final decided = claim.hasDecision;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final reviewDone = claim.status != ClaimStatus.submitted;
    final decisionColor = switch (claim.status) {
      ClaimStatus.approved => AppColors.success,
      ClaimStatus.rejected => AppColors.error,
      _ => muted ?? AppColors.textMutedLight,
    };
    final steps = [
      _TimelineData(
        title: 'Claim submitted',
        subtitle: AppFormatters.date(claim.submittedAt),
        icon: Icons.check_rounded,
        color: AppColors.success,
      ),
      _TimelineData(
        title: 'Under review',
        subtitle: reviewDone ? 'Our claims team is assessing your file' : 'Starts after submission',
        icon: reviewDone ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
        color: reviewDone ? AppColors.success : muted ?? AppColors.textMutedLight,
      ),
      _TimelineData(
        title: decided ? claim.status.label : 'Decision',
        subtitle: claim.reviewedAt != null
            ? 'Updated ${AppFormatters.date(claim.reviewedAt!)}'
            : 'Usually within 2-3 business days',
        icon: decided
            ? (claim.status == ClaimStatus.approved ? Icons.check_rounded : Icons.close_rounded)
            : Icons.schedule_rounded,
        color: decided ? decisionColor : muted ?? AppColors.textMutedLight,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Claim progress', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < steps.length; i++)
              _TimelineRow(data: steps[i], isLast: i == steps.length - 1),
          ],
        ),
      ),
    );
  }
}

class _TimelineData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _TimelineData({required this.title, required this.subtitle, required this.icon, required this.color});
}

class _TimelineRow extends StatelessWidget {
  final _TimelineData data;
  final bool isLast;

  const _TimelineRow({required this.data, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(data.icon, size: 15, color: data.color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 1),
                  Text(data.subtitle, style: Theme.of(context).textTheme.bodySmall),
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
    final hasNote = claim.reviewNotes != null && claim.reviewNotes!.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Decision & notes', style: Theme.of(context).textTheme.titleSmall),
                ),
                StatusBadge(label: claim.status.label),
              ],
            ),
            if (claim.reviewedAt != null) ...[
              const SizedBox(height: 4),
              Text('Reviewed ${AppFormatters.date(claim.reviewedAt!)}', style: Theme.of(context).textTheme.bodySmall),
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
                    hasNote ? 'Note from the claims team' : 'No additional note',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasNote ? claim.reviewNotes! : 'Our team did not add a note to this update.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            if (claim.status == ClaimStatus.rejected) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'To appeal, contact support within 30 days and quote ${claim.claimNumber}. Include any new evidence that supports your claim.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final Claim claim;
  const _DetailsCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Claim information', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.md),
            _DetailRow(label: 'Claim type', value: claim.type.label),
            _DetailRow(label: 'Incident date', value: AppFormatters.date(claim.incidentDate)),
            _DetailRow(label: 'Submitted', value: AppFormatters.date(claim.submittedAt)),
            const Divider(height: AppSpacing.lg),
            Text('What you reported', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(claim.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55)),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
