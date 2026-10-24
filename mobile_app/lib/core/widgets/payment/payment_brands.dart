import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';

class PaymentBrand {
  final String name;
  final String shortName;
  final Color color;
  final String accountName;
  final String accountNumber;

  const PaymentBrand({
    required this.name,
    required this.shortName,
    required this.color,
    required this.accountName,
    required this.accountNumber,
  });
}

const demoBanks = <PaymentBrand>[
  PaymentBrand(
    name: 'ABA Bank',
    shortName: 'ABA',
    color: Color(0xFF0A4C95),
    accountName: 'TRUSTGUARD INSURANCE CO., LTD.',
    accountNumber: '000 123 456',
  ),
  PaymentBrand(
    name: 'ACLEDA Bank',
    shortName: 'ACLEDA',
    color: Color(0xFF1E5AA8),
    accountName: 'TRUSTGUARD INSURANCE CO., LTD.',
    accountNumber: '0200 11 345 678',
  ),
  PaymentBrand(
    name: 'Canadia Bank',
    shortName: 'Canadia',
    color: Color(0xFF0091D2),
    accountName: 'TRUSTGUARD INSURANCE CO., LTD.',
    accountNumber: '000 998 771',
  ),
  PaymentBrand(
    name: 'Wing Bank',
    shortName: 'Wing',
    color: Color(0xFF00A651),
    accountName: 'TRUSTGUARD INSURANCE CO., LTD.',
    accountNumber: '012 345 678',
  ),
];

const demoWallets = <PaymentBrand>[
  PaymentBrand(
    name: 'ABA Pay',
    shortName: 'ABA Pay',
    color: Color(0xFF0A4C95),
    accountName: 'TRUSTGUARD INSURANCE',
    accountNumber: 'ABA-889 120',
  ),
  PaymentBrand(
    name: 'ACLEDA ToanChet',
    shortName: 'ToanChet',
    color: Color(0xFF1E5AA8),
    accountName: 'TRUSTGUARD INSURANCE',
    accountNumber: 'ACL-552 091',
  ),
  PaymentBrand(
    name: 'TrueMoney',
    shortName: 'TrueMoney',
    color: Color(0xFFF58220),
    accountName: 'TRUSTGUARD INSURANCE',
    accountNumber: 'TMN-338 470',
  ),
  PaymentBrand(
    name: 'Wing Wallet',
    shortName: 'Wing',
    color: Color(0xFF00A651),
    accountName: 'TRUSTGUARD INSURANCE',
    accountNumber: 'WNG-771 204',
  ),
];

String demoQrPayload({
  required String brand,
  required String accountNumber,
  required double amount,
  required String reference,
}) {
  return 'TRUSTGUARD-DEMO|BRAND:$brand|ACC:$accountNumber|AMT:${amount.toStringAsFixed(2)}|CCY:USD|REF:$reference';
}

class BrandMark extends StatelessWidget {
  final PaymentBrand brand;
  final double size;

  const BrandMark({super.key, required this.brand, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: size * 0.08),
      decoration: BoxDecoration(
        color: brand.color,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: brand.color.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          brand.shortName,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.26,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class BrandChoiceTile extends StatelessWidget {
  final PaymentBrand brand;
  final bool selected;
  final VoidCallback onTap;

  const BrandChoiceTile({
    super.key,
    required this.brand,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).dividerColor;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? brand.color.withValues(alpha: 0.07)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? brand.color : border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            BrandMark(brand: brand, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                brand.name,
                maxLines: 2,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontSize: 13),
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 19,
              color: selected ? brand.color : Theme.of(context).disabledColor,
            ),
          ],
        ),
      ),
    );
  }
}

class DemoBadge extends StatelessWidget {
  final String label;
  final Color color;

  const DemoBadge({
    super.key,
    required this.label,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science_outlined, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
