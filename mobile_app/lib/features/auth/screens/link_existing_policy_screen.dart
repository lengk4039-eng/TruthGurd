import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/insurance_category.dart';
import '../../../core/models/policy.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_controller.dart';

class LinkExistingPolicyScreen extends ConsumerStatefulWidget {
  const LinkExistingPolicyScreen({super.key});

  @override
  ConsumerState<LinkExistingPolicyScreen> createState() =>
      _LinkExistingPolicyScreenState();
}

class _LinkExistingPolicyScreenState
    extends ConsumerState<LinkExistingPolicyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _policyNumber = TextEditingController();
  final _dob = TextEditingController();
  bool _isSubmitting = false;
  String? _error;
  Policy? _linked;

  @override
  void dispose() {
    _policyNumber.dispose();
    _dob.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dob.text =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final policy = await ref
          .read(authStateProvider.notifier)
          .linkExistingPolicy(
            policyNumber: _policyNumber.text,
            dateOfBirth: _dob.text,
          );
      setState(() => _linked = policy);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('AppException: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(context.l10n.tr('linkPolicy.title')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _linked != null
              ? _buildSuccess(context, _linked!)
              : _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.badge_outlined,
              color: AppColors.brandInk,
              size: 30,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.tr('linkPolicy.heading'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.tr('linkPolicy.body'),
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: l10n.tr('linkPolicy.policyNumber'),
            controller: _policyNumber,
            prefixIcon: Icons.confirmation_number_outlined,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? l10n.tr('linkPolicy.policyNumberError')
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: l10n.tr('linkPolicy.dob'),
            controller: _dob,
            hint: l10n.tr('linkPolicy.dobHint'),
            enabled: true,
            prefixIcon: Icons.cake_outlined,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? l10n.tr('linkPolicy.dobError')
                : null,
          ),
          TextButton.icon(
            onPressed: _pickDob,
            icon: const Icon(Icons.calendar_month_outlined, size: 16),
            label: Text(l10n.tr('linkPolicy.chooseDate')),
          ),
          if (_error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.tr('linkPolicy.demoTip'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PrimaryButton(
            label: l10n.tr('linkPolicy.verify'),
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: () => context.go('/home'),
              child: Text(l10n.tr('linkPolicy.skip')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, Policy policy) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.success,
            size: 36,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.tr('linkPolicy.successTitle'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.tr('linkPolicy.successBody', {'name': policy.package.name}),
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    policy.package.category.icon,
                    color: AppColors.brandInk,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy.package.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        policy.policyNumber,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  AppFormatters.currencyWhole(policy.nextPaymentAmount ?? 0),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: l10n.tr('linkPolicy.goToPolicies'),
          onPressed: () => context.go('/my-policies'),
        ),
      ],
    );
  }
}
