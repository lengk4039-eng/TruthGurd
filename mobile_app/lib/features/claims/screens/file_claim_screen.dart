import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/claim.dart';
import '../../../core/models/claim_eligibility.dart';
import '../../../core/models/insurance_category.dart';
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
    final windowStart = now.subtract(Duration(days: eligibility.claimWindowDays));
    final firstDate = policy.startDate.isAfter(windowStart) ? policy.startDate : windowStart;
    final initialDate = _incidentDate.isBefore(firstDate)
        ? firstDate
        : (_incidentDate.isAfter(now) ? now : _incidentDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now,
      helpText: 'Incident date',
    );
    if (picked != null) setState(() => _incidentDate = picked);
  }

  Future<void> _submit(Policy policy, ClaimType type) async {
    if (_submitting) return;
    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (description.isEmpty) {
      setState(() => _error = 'Please describe what happened.');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid claim amount.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final claim = await ref.read(claimsRepositoryProvider).submitClaim(
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
    final eligibilityAsync = ref.watch(claimEligibilityProvider(widget.policyId));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('File a claim'),
      ),
      body: AsyncValueView(
        value: policyAsync,
        onRetry: () => ref.invalidate(policyDetailProvider(widget.policyId)),
        builder: (policy) => AsyncValueView(
          value: eligibilityAsync,
          onRetry: () => ref.invalidate(claimEligibilityProvider(widget.policyId)),
          builder: (eligibility) => _buildBody(context, policy, eligibility),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Policy policy, ClaimEligibility eligibility) {
    final waiting = eligibility.eligible && eligibility.withinWaitingPeriod;
    final allowedTypes = waiting ? const [ClaimType.accident] : ClaimType.values;
    final selectedType = waiting ? ClaimType.accident : _type;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
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
          Text('Claim details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Claim type', style: Theme.of(context).textTheme.titleSmall),
                  if (waiting) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Only accident claims are available during the waiting period.',
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
                        label: Text(type.label),
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
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
                                Text('Incident date', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 2),
                                Text(
                                  AppFormatters.date(_incidentDate),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Within ${eligibility.claimWindowDays} days',
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
                    label: 'Claimed amount',
                    hint: 'e.g. 250',
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: Icons.attach_money_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'What happened?',
                    hint: 'Describe the incident, when it happened and any treatment received',
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
                Icon(Icons.error_outline_rounded, size: 18, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Submit claim',
            icon: Icons.send_rounded,
            isLoading: _submitting,
            onPressed: _submitting ? null : () => _submit(policy, selectedType),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'By submitting, you confirm the information is true and complete. False or misleading information can delay or void a claim.',
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
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(policy.package.category.icon, color: AppColors.primary, size: 21),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(policy.package.name, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(policy.policyNumber, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            StatusBadge(label: policy.status.label),
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
    final waiting = eligibility.withinWaitingPeriod;
    final color = waiting ? AppColors.warning : AppColors.success;
    final icon = waiting ? Icons.hourglass_top_rounded : Icons.verified_user_rounded;
    final title = waiting ? 'Waiting period active' : 'Claim protection active';
    final message = waiting
        ? '${eligibility.message}'
          '${eligibility.waitingPeriodEndsAt != null ? ' Waiting period ends ${AppFormatters.date(eligibility.waitingPeriodEndsAt!)}.' : ''}'
        : 'Your policy is active and premiums are up to date. File this claim within ${eligibility.claimWindowDays} days of the incident.';

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
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
                const SizedBox(height: 4),
                Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5)),
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
    final canPay = eligibility.canPayOverdue;
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
            child: const Icon(Icons.gpp_maybe_rounded, color: AppColors.error, size: 24),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            eligibility.title.isEmpty ? 'Claim filing unavailable' : eligibility.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(eligibility.message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55)),
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
                  const Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Outstanding ${AppFormatters.currency(eligibility.overdueAmount!)}'
                      '${eligibility.overdueDueDate != null ? ' · due ${AppFormatters.date(eligibility.overdueDueDate!)}' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (canPay) ...[
            PrimaryButton(
              label: 'Pay overdue installment',
              icon: Icons.payments_rounded,
              onPressed: () => context.push('/payments/${eligibility.overduePaymentId}'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewPolicy,
              icon: const Icon(Icons.shield_outlined),
              label: const Text('View policy & payment schedule'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            switch (eligibility.code) {
              'PAYMENT_OVERDUE' => 'Cover resumes automatically once the outstanding installment is paid. This check runs again when you reopen the claim form.',
              'PREMIUM_UNPAID' => 'Cover begins after the first premium is paid. Open the policy to settle the first invoice.',
              _ => 'Expired cover cannot receive new claims. Renew the plan or contact support if you believe this is a mistake.',
            },
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Policy ${policy.policyNumber}',
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
    final documents = package.claimDocuments.isEmpty
        ? const ['Proof of the incident', 'Invoices or receipts', 'Photo ID and policy certificate']
        : package.claimDocuments;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Before you file', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _TermTile(
                    icon: Icons.hourglass_bottom_rounded,
                    label: 'Waiting period',
                    value: '${package.waitingPeriodDays} days',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TermTile(
                    icon: Icons.event_available_rounded,
                    label: 'File within',
                    value: '${eligibility.claimWindowDays} days',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Documents to prepare', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            for (final document in documents)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.description_outlined, size: 15, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(document, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4))),
                  ],
                ),
              ),
            if (package.claimPolicy.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  leading: const Icon(Icons.policy_outlined, color: AppColors.primary, size: 20),
                  title: Text('Claim policy summary', style: Theme.of(context).textTheme.titleSmall),
                  children: [
                    Text(
                      package.claimPolicy,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.55),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              'You can add photos or reports later if our claims team asks for them.',
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

  const _TermTile({required this.icon, required this.label, required this.value});

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
          Icon(icon, size: 18, color: AppColors.primary),
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
