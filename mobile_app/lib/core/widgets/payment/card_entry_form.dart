import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/card_formatters.dart';

class CardFormController {
  final formKey = GlobalKey<FormState>();
  final holderController = TextEditingController();
  final numberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  CardBrand get brand => CardUtils.detectBrand(numberController.text);

  String get instrumentLabel =>
      '${brand == CardBrand.unknown ? 'Card' : brand.label} ${CardUtils.mask(numberController.text)}';

  bool validate() => formKey.currentState?.validate() ?? false;

  void fillDemo() {
    holderController.text = 'JORDAN LEE';
    numberController.text = '4242 4242 4242 4242';
    expiryController.text = CardUtils.demoExpiry();
    cvvController.text = '123';
  }

  void dispose() {
    holderController.dispose();
    numberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
  }
}

class CardEntryForm extends StatelessWidget {
  final CardFormController controller;

  const CardEntryForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardPreview(controller: controller),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: AppColors.success,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  l10n.tr('payment.securePayment'),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.success, fontSize: 11.5),
                ),
              ),
              Text(
                l10n.tr('payment.cardAccepted'),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontSize: 10.5),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.tr('payment.cardDetails'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller.holderController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.creditCardName],
            decoration: InputDecoration(
              labelText: l10n.tr('payment.cardHolder'),
              hintText: l10n.tr('payment.cardHolderHint'),
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 2) {
                return l10n.tr('payment.validationName');
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller.numberController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.creditCardNumber],
            inputFormatters: [CardNumberInputFormatter()],
            decoration: InputDecoration(
              labelText: l10n.tr('payment.cardLabel'),
              hintText: l10n.tr('payment.cardNumberHint'),
              prefixIcon: const Icon(Icons.credit_card_rounded, size: 20),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller.numberController,
                builder: (context, value, _) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        CardUtils.detectBrand(value.text).label.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            validator: (value) {
              if (value == null || !CardUtils.isValidNumber(value)) {
                return l10n.tr('payment.validationNumber');
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.expiryController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.creditCardExpirationDate],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ExpiryInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.tr('payment.expiry'),
                    hintText: l10n.tr('payment.expiryHint'),
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || !CardUtils.isValidExpiry(value)) {
                      return l10n.tr('payment.validationExpiry');
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: controller.cvvController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  autofillHints: const [AutofillHints.creditCardSecurityCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.tr('payment.cvv'),
                    hintText: l10n.tr('payment.cvvHint'),
                    prefixIcon: const Icon(Icons.password_rounded, size: 18),
                  ),
                  validator: (value) {
                    final brand = CardUtils.detectBrand(
                      controller.numberController.text,
                    );
                    if (value == null || !CardUtils.isValidCvv(value, brand)) {
                      return l10n.tr('payment.validationCvv');
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l10n.tr('payment.cardFormNote'),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontSize: 11.5),
                ),
              ),
              TextButton.icon(
                onPressed: controller.fillDemo,
                icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                label: Text(l10n.tr('payment.useDemoCard')),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  final CardFormController controller;

  const _CardPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller.holderController,
        controller.numberController,
        controller.expiryController,
      ]),
      builder: (context, _) {
        final brand = controller.brand;
        final number = controller.numberController.text.trim();
        final holder = controller.holderController.text.trim();
        final expiry = controller.expiryController.text.trim();
        return Container(
          height: 196,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            gradient: const LinearGradient(
              colors: [Color(0xFF312A63), Color(0xFF5B3FE4), Color(0xFF8A63F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.32),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 24,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Text(
                          'TRUSTGUARD PAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.contactless_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 23,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 39,
                          height: 29,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF6D98B), Color(0xFFD8AE4A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CustomPaint(painter: _ChipPainter()),
                        ),
                        const Spacer(),
                        Text(
                          brand.label.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            fontStyle: brand == CardBrand.amex
                                ? FontStyle.italic
                                : FontStyle.normal,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      number.isEmpty ? '••••  ••••  ••••  ••••' : number,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: brand == CardBrand.amex ? 18 : 19,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.6,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CARDHOLDER',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                holder.isEmpty
                                    ? 'YOUR NAME'
                                    : holder.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXPIRES',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              expiry.isEmpty ? 'MM/YY' : expiry,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = const Color(0xFF9A7B28).withValues(alpha: 0.55)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * 0.32, 0),
      Offset(size.width * 0.32, size.height),
      line,
    );
    canvas.drawLine(
      Offset(size.width * 0.66, 0),
      Offset(size.width * 0.66, size.height),
      line,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      line,
    );
    final inset = Paint()
      ..color = const Color(0xFF9A7B28).withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.32,
          size.height * 0.25,
          size.width * 0.34,
          size.height * 0.5,
        ),
        const Radius.circular(2),
      ),
      inset,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
