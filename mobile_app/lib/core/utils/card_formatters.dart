import 'dart:math' as math;

import 'package:flutter/services.dart';

enum CardBrand {
  visa('Visa'),
  mastercard('Mastercard'),
  amex('American Express'),
  jcb('JCB'),
  discover('Discover'),
  unknown('Card');

  const CardBrand(this.label);

  final String label;
}

class CardUtils {
  CardUtils._();

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  static CardBrand detectBrand(String raw) {
    final digits = digitsOnly(raw);
    if (digits.isEmpty) return CardBrand.unknown;
    if (digits.startsWith('4')) return CardBrand.visa;
    if (digits.startsWith('34') || digits.startsWith('37')) {
      return CardBrand.amex;
    }

    final two = int.tryParse(digits.length >= 2 ? digits.substring(0, 2) : '');
    if (two != null && two >= 51 && two <= 55) return CardBrand.mastercard;

    final four = int.tryParse(digits.length >= 4 ? digits.substring(0, 4) : '');
    if (four != null) {
      if (four >= 2221 && four <= 2720) return CardBrand.mastercard;
      if (four >= 3528 && four <= 3589) return CardBrand.jcb;
      if (four >= 6011 && four <= 6011) return CardBrand.discover;
      if (four >= 6440 && four <= 6499) return CardBrand.discover;
    }
    if (digits.startsWith('65')) return CardBrand.discover;
    return CardBrand.unknown;
  }

  static int maxDigits(CardBrand brand) => brand == CardBrand.amex ? 15 : 16;

  static int cvvLength(CardBrand brand) => brand == CardBrand.amex ? 4 : 3;

  static bool luhnValid(String raw) {
    final digits = digitsOnly(raw);
    if (digits.length < 12) return false;
    var sum = 0;
    var doubleDigit = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var digit = int.parse(digits[i]);
      if (doubleDigit) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      doubleDigit = !doubleDigit;
    }
    return sum % 10 == 0;
  }

  static bool isValidNumber(String raw) {
    final digits = digitsOnly(raw);
    final brand = detectBrand(digits);
    if (digits.length != maxDigits(brand)) return false;
    return luhnValid(digits);
  }

  static bool isValidExpiry(String raw) {
    final digits = digitsOnly(raw);
    if (digits.length != 4) return false;
    final month = int.tryParse(digits.substring(0, 2));
    final year = int.tryParse(digits.substring(2));
    if (month == null || year == null || month < 1 || month > 12) return false;
    final lastDay = DateTime(2000 + year, month + 1, 0);
    final today = DateTime.now();
    return !lastDay.isBefore(DateTime(today.year, today.month, today.day));
  }

  static bool isValidCvv(String raw, CardBrand brand) {
    final digits = digitsOnly(raw);
    if (brand == CardBrand.unknown) {
      return digits.length == 3 || digits.length == 4;
    }
    return digits.length == cvvLength(brand);
  }

  static String formatCardNumber(String raw) {
    final digits = digitsOnly(raw);
    final brand = detectBrand(digits);
    final limited = digits.length > maxDigits(brand)
        ? digits.substring(0, maxDigits(brand))
        : digits;
    if (brand == CardBrand.amex) {
      final chunks = <String>[];
      for (var i = 0; i < limited.length; i += 6) {
        chunks.add(limited.substring(i, math.min(i + 6, limited.length)));
      }
      return chunks.join('  ');
    }
    final chunks = <String>[];
    for (var i = 0; i < limited.length; i += 4) {
      chunks.add(limited.substring(i, math.min(i + 4, limited.length)));
    }
    return chunks.join(' ');
  }

  static String formatExpiry(String raw) {
    var digits = digitsOnly(raw);
    if (digits.length == 1 && int.parse(digits) > 1) digits = '0$digits';
    if (digits.length > 4) digits = digits.substring(0, 4);
    if (digits.length <= 2) return digits;
    return '${digits.substring(0, 2)}/${digits.substring(2)}';
  }

  static String formatHolder(String raw) => raw.toUpperCase();

  static String demoExpiry() {
    final now = DateTime.now();
    final year = (now.year + 2) % 100;
    return '${now.month.toString().padLeft(2, '0')}/${year.toString().padLeft(2, '0')}';
  }

  static String lastFour(String raw) {
    final digits = digitsOnly(raw);
    return digits.length <= 4 ? digits : digits.substring(digits.length - 4);
  }

  static String mask(String raw, {String unknown = '••••'}) {
    final last4 = lastFour(raw);
    return last4.isEmpty ? unknown : '•••• $last4';
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = CardUtils.formatCardNumber(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = CardUtils.formatExpiry(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
