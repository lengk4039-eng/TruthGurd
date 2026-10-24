import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../localization/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/formatters.dart';
import 'payment_brands.dart';

class QrPaymentPanel extends StatelessWidget {
  final List<PaymentBrand> brands;
  final PaymentBrand selectedBrand;
  final ValueChanged<PaymentBrand> onBrandSelected;
  final double amount;
  final String reference;
  final bool wallet;

  const QrPaymentPanel({
    super.key,
    required this.brands,
    required this.selectedBrand,
    required this.onBrandSelected,
    required this.amount,
    required this.reference,
    this.wallet = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tr(wallet ? 'payment.chooseWallet' : 'payment.chooseBank'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final brand in brands)
                  SizedBox(
                    width: tileWidth,
                    child: BrandChoiceTile(
                      brand: brand,
                      selected: brand.name == selectedBrand.name,
                      onTap: () => onBrandSelected(brand),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.tr(
                  wallet ? 'payment.walletQrTitle' : 'payment.bankQrTitle',
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            DemoBadge(
              label: l10n.tr(
                wallet ? 'payment.walletBadge' : 'payment.bankQrBadge',
              ),
              color: selectedBrand.color,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.tr(wallet ? 'payment.walletBody' : 'payment.scanBody', {
            'wallet': selectedBrand.name,
            'bank': selectedBrand.name,
          }),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        _QrCard(
          brand: selectedBrand,
          amount: amount,
          reference: reference,
          wallet: wallet,
        ),
        const SizedBox(height: AppSpacing.md),
        _DetailsCard(
          brand: selectedBrand,
          amount: amount,
          reference: reference,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.science_outlined,
                size: 17,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.tr(
                    wallet ? 'payment.walletDemoNote' : 'payment.demoQrNote',
                  ),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontSize: 11.5, color: muted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QrCard extends StatelessWidget {
  final PaymentBrand brand;
  final double amount;
  final String reference;
  final bool wallet;

  const _QrCard({
    required this.brand,
    required this.amount,
    required this.reference,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final payload = demoQrPayload(
      brand: brand.name,
      accountNumber: brand.accountNumber,
      amount: amount,
      reference: reference,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          colors: [
            brand.color.withValues(alpha: 0.12),
            Theme.of(context).cardColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: brand.color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              BrandMark(brand: brand, size: 32),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.tr(
                    wallet ? 'payment.scanWithWallet' : 'payment.scanWith',
                    {'wallet': brand.name, 'bank': brand.name},
                  ),
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: brand.color,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  l10n.tr('payment.demoQr'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: QrImageView(
              data: payload,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: brand.color,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1B1730),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            AppFormatters.currency(amount),
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: brand.color, fontSize: 22),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.tr('payment.qrExpiry'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final PaymentBrand brand;
  final double amount;
  final String reference;

  const _DetailsCard({
    required this.brand,
    required this.amount,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          _row(context, l10n.tr('payment.accountName'), brand.accountName),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          InkWell(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: brand.accountNumber));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.tr('common.copied'))),
                );
              }
            },
            child: _row(
              context,
              l10n.tr('payment.accountNumber'),
              brand.accountNumber,
              trailing: Icon(
                Icons.copy_rounded,
                size: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          _row(
            context,
            l10n.tr('payment.transferAmount'),
            AppFormatters.currency(amount),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          _row(context, l10n.tr('payment.transferReference'), reference),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontSize: 12),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontSize: 12.5, letterSpacing: 0.1),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 5), trailing],
            ],
          ),
        ),
      ],
    );
  }
}
