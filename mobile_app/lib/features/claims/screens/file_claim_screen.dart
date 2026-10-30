import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/claim.dart';
import '../../../core/models/claim_eligibility.dart';
import '../../../core/models/insurance_package.dart';
import '../../../core/models/policy.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/category_image.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_badge.dart';

class FileClaimScreen extends ConsumerStatefulWidget {
  final String policyId;
  const FileClaimScreen({super.key, required this.policyId});

  @override
  ConsumerState<FileClaimScreen> createState() => _FileClaimScreenState();
}

class _FileClaimScreenState extends ConsumerState<FileClaimScreen> {
  ClaimType _type = ClaimType.medical;
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _incidentDate = DateTime.now().subtract(const Duration(days: 1));
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(Policy policy, ClaimEligibility eligibility) async {
    final now = DateTime.now();
    final windowStart = now.subtract(
      Duration(days: eligibility.claimWindowDays),
    );
    final firstDate = policy.startDate.isAfter(windowStart)
        ? policy.startDate
        : windowStart;
    final initialDate = _incidentDate.isBefore(firstDate)
        ? firstDate
        : (_incidentDate.isAfter(now) ? now : _incidentDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now,
      helpText: context.l10n.tr('claimForm.incidentDate'),
    );
    if (picked != null) setState(() => _incidentDate = picked);
  }

  Future<void> _submit(Policy policy, ClaimType type) async {
    if (_submitting) return;
    final l10n = context.l10n;
    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (description.isEmpty) {
      setState(() => _error = l10n.tr('claimForm.errorDescription'));
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = l10n.tr('claimForm.errorAmount'));
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final claim = await ref
          .read(claimsRepositoryProvider)
          .submitClaim(
            policyId: policy.id,
            type: type,
            description: description,
            amount: amount,
            incidentDate: _incidentDate,
          );
      ref.invalidate(myClaimsProvider);
      ref.invalidate(myNotificationsProvider);
      ref.invalidate(claimsForPolicyProvider(policy.id));
      if (!mounted) return;
      context.pushReplacement('/claims/${claim.id}');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('AppException: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final policyAsync = ref.watch(policyDetailProvider(widget.policyId));
    final eligibilityAsync = ref.watch(
      claimEligibilityProvider(widget.policyId),
    );

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(context.l10n.tr('claimForm.title')),
      ),
      body: AsyncValueView(
        value: policyAsync,
        onRetry: () => ref.invalidate(policyDetailProvider(widget.policyId)),
        builder: (policy) => AsyncValueView(
          value: eligibilityAsync,
          onRetry: () =>
              ref.invalidate(claimEligibilityProvider(widget.policyId)),
          builder: (eligibility) => _buildBody(context, policy, eligibility),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    Policy policy,
    ClaimEligibility eligibility,
  ) {
    final l10n = context.l10n;
    final waiting = eligibility.eligible && eligibility.withinWaitingPeriod;
    final allowedTypes = waiting
        ? const [ClaimType.accident]
        : ClaimType.values;
    final selectedType = waiting ? ClaimType.accident : _type;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        _PolicySummaryCard(policy: policy),
        const SizedBox(height: AppSpacing.lg),
        if (!eligibility.eligible)
          _ProtectionBlockCard(
            policy: policy,
            eligibility: eligibility,
            onViewPolicy: () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
              } else {
                context.go('/my-policies/${policy.id}');
              }
            },
          )
        else ...[
          _CoverStatusCard(eligibility: eligibility),
          const SizedBox(height: AppSpacing.lg),
          _BeforeYouFileCard(package: policy.package, eligibility: eligibility),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.tr('claimForm.details'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tr('claimForm.claimType'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (waiting) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.tr('claimForm.accidentOnly'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allowedTypes.map((type) {
                      final selected = selectedType == type;
                      return ChoiceChip(
                        label: Text(l10n.claimType(type)),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _type = type),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : null,
                          fontWeight: selected ? FontWeight.w600 : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: () => _pickDate(policy, eligibility),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 19),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.tr('claimForm.incidentDate'),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.formatDate(_incidentDate),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            l10n.tr('claimForm.withinDays', {
                              'count': '${eligibility.claimWindowDays}',
                            }),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: l10n.tr('claimForm.amount'),
                    hint: l10n.tr('claimForm.amountHint'),
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.attach_money_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: l10n.tr('claimForm.description'),
                    hint: l10n.tr('claimForm.descriptionHint'),
                    controller: _descriptionController,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: l10n.tr('claimForm.submit'),
            icon: Icons.send_rounded,
            isLoading: _submitting,
            onPressed: _submitting ? null : () => _submit(policy, selectedType),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.tr('claimForm.consent'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _PolicySummaryCard extends StatelessWidget {
  final Policy policy;
  const _PolicySummaryCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CategoryImage(
              category: policy.package.category,
              size: 44,
              radius: AppRadius.sm,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    policy.package.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    policy.policyNumber,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            StatusBadge(label: context.l10n.policyStatus(policy.status)),
          ],
        ),
      ),
    );
  }
}

class _CoverStatusCard extends StatelessWidget {
  final ClaimEligibility eligibility;
  const _CoverStatusCard({required this.eligibility});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final waiting = eligibility.withinWaitingPeriod;
    final color = waiting ? AppColors.warning : AppColors.success;
    final icon = waiting
        ? Icons.hourglass_top_rounded
        : Icons.verified_user_rounded;
    final title = waiting
        ? l10n.tr('policy.waitingPeriod')
        : l10n.tr('policy.claimProtection');
    final message = waiting
        ? (eligibility.waitingPeriodEndsAt != null
              ? l10n.tr('claimForm.waitingBody', {
                  'date': l10n.formatDate(eligibility.waitingPeriodEndsAt!),
                  'count': '${eligibility.waitingPeriodDays}',
                })
              : l10n.tr('claimForm.waitingBodyNoDate', {
                  'count': '${eligibility.waitingPeriodDays}',
                }))
        : l10n.tr('claimForm.protectionBody', {
            'count': '${eligibility.claimWindowDays}',
          });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionBlockCard extends StatelessWidget {
  final Policy policy;
  final ClaimEligibility eligibility;
  final VoidCallback onViewPolicy;

  const _ProtectionBlockCard({
    required this.policy,
    required this.eligibility,
    required this.onViewPolicy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canPay = eligibility.canPayOverdue;
    final title = switch (eligibility.code) {
      'PAYMENT_OVERDUE' => l10n.tr('claimForm.titleOverdue'),
      'PREMIUM_UNPAID' => l10n.tr('claimForm.titleUnpaid'),
      'POLICY_INACTIVE' => l10n.tr('claimForm.titleExpired'),
      _ =>
        eligibility.title.isEmpty
            ? l10n.tr('policy.claimUnavailable')
            : eligibility.title,
    };
    final message = switch (eligibility.code) {
      'PAYMENT_OVERDUE' => l10n.tr('claimForm.messageOverdue'),
      'PREMIUM_UNPAID' => l10n.tr('claimForm.messageUnpaid'),
      'POLICY_INACTIVE' => l10n.tr('claimForm.messageExpired'),
      _ => eligibility.message,
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.gpp_maybe_rounded,
              color: AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(height: 1.55),
          ),
          if (eligibility.overdueAmount != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      eligibility.overdueDueDate != null
                          ? l10n.tr('claimForm.outstandingDue', {
                              'amount': AppFormatters.currency(
                                eligibility.overdueAmount!,
                              ),
                              'date': l10n.formatDate(
                                eligibility.overdueDueDate!,
                              ),
                            })
                          : l10n.tr('policy.outstanding', {
                              'amount': AppFormatters.currency(
                                eligibility.overdueAmount!,
                              ),
                            }),
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (canPay) ...[
            PrimaryButton(
              label: l10n.tr('policy.payOverdue'),
              icon: Icons.payments_rounded,
              onPressed: () =>
                  context.push('/payments/${eligibility.overduePaymentId}'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewPolicy,
              icon: const Icon(Icons.shield_outlined),
              label: Text(l10n.tr('claimForm.viewPolicy')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(switch (eligibility.code) {
            'PAYMENT_OVERDUE' => l10n.tr('claimForm.overdueNote'),
            'PREMIUM_UNPAID' => l10n.tr('claimForm.unpaidNote'),
            _ => l10n.tr('claimForm.expiredNote'),
          }, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            l10n.tr('claimForm.policyNumber', {'number': policy.policyNumber}),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _BeforeYouFileCard extends StatelessWidget {
  final InsurancePackage package;
  final ClaimEligibility eligibility;

  const _BeforeYouFileCard({required this.package, required this.eligibility});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final documents = package.claimDocuments.isEmpty
        ? [
            l10n.tr('packages.defaultDocProof'),
            l10n.tr('packages.defaultDocInvoices'),
            l10n.tr('packages.defaultDocId'),
          ]
        : package.claimDocuments;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tr('claimForm.beforeYouFile'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _TermTile(
                    icon: Icons.hourglass_bottom_rounded,
                    label: l10n.tr('packages.waitingPeriod'),
                    value: l10n.tr('packages.days', {
                      'count': '${package.waitingPeriodDays}',
                    }),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TermTile(
                    icon: Icons.event_available_rounded,
                    label: l10n.tr('packages.fileWithin'),
                    value: l10n.tr('packages.days', {
                      'count': '${eligibility.claimWindowDays}',
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.tr('packages.documents'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final document in documents)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.description_outlined,
                        size: 15,
                        color: AppColors.brandInk,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        document,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            if (package.claimPolicy.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  leading: const Icon(
                    Icons.policy_outlined,
                    color: AppColors.brandInk,
                    size: 20,
                  ),
                  title: Text(
                    l10n.tr('claimForm.policySummary'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  children: [
                    Text(
                      package.claimPolicy,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(height: 1.55),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.tr('claimForm.docsLater'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TermTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TermTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.brandInk),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 1),
                Text(value, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
