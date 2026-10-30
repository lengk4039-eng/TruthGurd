import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/payment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/formatters.dart';
import '../primary_button.dart';
import 'card_entry_form.dart';
import 'payment_brands.dart';
import 'payment_processing_dialog.dart';
import 'qr_payment_panel.dart';

class PaymentCheckoutView extends StatefulWidget {
  final double amount;
  final String reference;
  final Widget? header;
  final String? notice;
  final Future<void> Function(PaymentMethod method) onPay;
  final void Function(PaymentMethod method, String instrumentLabel) onPaid;
  final String? payLabel;

  const PaymentCheckoutView({
    super.key,
    required this.amount,
    required this.reference,
    required this.onPay,
    required this.onPaid,
    this.header,
    this.notice,
    this.payLabel,
  });

  @override
  State<PaymentCheckoutView> createState() => _PaymentCheckoutViewState();
}

class _PaymentCheckoutViewState extends State<PaymentCheckoutView> {
  final CardFormController _card = CardFormController();
  PaymentMethod _method = PaymentMethod.card;
  int _bankIndex = 0;
  int _walletIndex = 0;
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _card.dispose();
    super.dispose();
  }

  PaymentBrand get _bank => demoBanks[_bankIndex];
  PaymentBrand get _wallet => demoWallets[_walletIndex];

  String get _instrument {
    switch (_method) {
      case PaymentMethod.card:
        return _card.instrumentLabel;
      case PaymentMethod.bankTransfer:
        return '${_bank.name} QR';
      case PaymentMethod.eWallet:
        return _wallet.name;
    }
  }

  String _ctaLabel(AppLocalizations l10n) {
    if (widget.payLabel != null) return widget.payLabel!;
    switch (_method) {
      case PaymentMethod.card:
        return l10n.tr('payment.payAmount', {
          'amount': AppFormatters.currency(widget.amount),
        });
      case PaymentMethod.bankTransfer:
        return l10n.tr('payment.completedTransfer');
      case PaymentMethod.eWallet:
        return l10n.tr('payment.payWithWallet', {'wallet': _wallet.name});
    }
  }

  List<String> _processingSteps(AppLocalizations l10n) {
    switch (_method) {
      case PaymentMethod.card:
        return [
          l10n.tr('payment.processingStep1'),
          l10n.tr('payment.processingStep2'),
          l10n.tr('payment.processingStep3'),
        ];
      case PaymentMethod.bankTransfer:
        return [
          l10n.tr('payment.processingBank1', {'bank': _bank.name}),
          l10n.tr('payment.processingBank2'),
          l10n.tr('payment.processingStep3'),
        ];
      case PaymentMethod.eWallet:
        return [
          l10n.tr('payment.processingWallet1', {'wallet': _wallet.name}),
          l10n.tr('payment.processingStep2'),
          l10n.tr('payment.processingStep3'),
        ];
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

    if (_method == PaymentMethod.card && !_card.validate()) return;

    setState(() => _submitting = true);
    final instrument = _instrument;
    try {
      await runPaymentProcessing(
        context: context,
        steps: _processingSteps(context.l10n),
        action: () => widget.onPay(_method),
      );
      if (!mounted) return;
      widget.onPaid(_method, instrument);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('AppException: ', '');
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: [
              if (widget.header != null) ...[
                widget.header!,
                const SizedBox(height: AppSpacing.lg),
              ],
              if (widget.notice != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.075),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        size: 17,
                        color: AppColors.brandInk,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.notice!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.brandInk,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Text(
                l10n.tr('payment.chooseMethod'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 3),
              Text(
                l10n.tr('payment.chooseMethodSubtitle'),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final method in PaymentMethod.values) ...[
                _MethodOption(
                  method: method,
                  selected: _method == method,
                  onTap: () => setState(() {
                    _method = method;
                    _error = null;
                  }),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.sm),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: switch (_method) {
                  PaymentMethod.card => Padding(
                    key: const ValueKey('card'),
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: CardEntryForm(controller: _card),
                  ),
                  PaymentMethod.bankTransfer => Padding(
                    key: const ValueKey('bank'),
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: QrPaymentPanel(
                      brands: demoBanks,
                      selectedBrand: _bank,
                      onBrandSelected: (brand) =>
                          setState(() => _bankIndex = demoBanks.indexOf(brand)),
                      amount: widget.amount,
                      reference: widget.reference,
                    ),
                  ),
                  PaymentMethod.eWallet => Padding(
                    key: const ValueKey('wallet'),
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: QrPaymentPanel(
                      brands: demoWallets,
                      selectedBrand: _wallet,
                      onBrandSelected: (brand) => setState(
                        () => _walletIndex = demoWallets.indexOf(brand),
                      ),
                      amount: widget.amount,
                      reference: widget.reference,
                      wallet: true,
                    ),
                  ),
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 17,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        _BottomBar(
          amount: widget.amount,
          label: _ctaLabel(l10n),
          icon: switch (_method) {
            PaymentMethod.card => Icons.lock_rounded,
            PaymentMethod.bankTransfer => Icons.check_circle_outline_rounded,
            PaymentMethod.eWallet => Icons.open_in_new_rounded,
          },
          note: l10n.tr(
            _method == PaymentMethod.card
                ? 'payment.secureNote'
                : 'payment.demoNote',
          ),
          isLoading: _submitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _MethodOption extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _MethodOption({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (icon, title, subtitle, color) = switch (method) {
      PaymentMethod.card => (
        Icons.credit_card_rounded,
        l10n.tr('payment.card'),
        l10n.tr('payment.cardSubtitle'),
        AppColors.primary,
      ),
      PaymentMethod.bankTransfer => (
        Icons.qr_code_2_rounded,
        l10n.tr('payment.bank'),
        l10n.tr('payment.bankSubtitle'),
        const Color(0xFF2E7DD7),
      ),
      PaymentMethod.eWallet => (
        Icons.account_balance_wallet_rounded,
        l10n.tr('payment.wallet'),
        l10n.tr('payment.walletSubtitle'),
        AppColors.success,
      ),
    };
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.065) : theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? color : theme.dividerColor,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: selected ? 0.14 : 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(fontSize: 13.5),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? color : theme.disabledColor,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final double amount;
  final String label;
  final IconData icon;
  final String note;
  final bool isLoading;
  final VoidCallback onPressed;

  const _BottomBar({
    required this.amount,
    required this.label,
    required this.icon,
    required this.note,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.tr('payment.totalDue'),
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    AppFormatters.currency(amount),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 21,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm + 2),
              PrimaryButton(
                label: label,
                icon: icon,
                isLoading: isLoading,
                onPressed: isLoading ? null : onPressed,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLoading
                        ? Icons.hourglass_top_rounded
                        : Icons.info_outline_rounded,
                    size: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      note,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
