import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../models/claim.dart';
import '../models/insurance_category.dart';
import '../models/payment.dart';
import '../models/policy.dart';
import '../models/quotation.dart';
import '../utils/formatters.dart';
import 'strings_en.dart';
import 'strings_km.dart';

enum AppLanguage {
  english('en', 'English', 'English'),
  khmer('km', 'Khmer', 'ខ្មែរ');

  const AppLanguage(this.code, this.englishName, this.nativeName);

  final String code;
  final String englishName;
  final String nativeName;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    return values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

class AppLocalizations {
  const AppLocalizations(this.language);

  final AppLanguage language;

  static const supportedLocales = [Locale('en'), Locale('km')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  bool get isKhmer => language == AppLanguage.khmer;

  String tr(String key, [Map<String, String>? args]) {
    var value = _strings[language]?[key] ?? stringsEn[key] ?? key;
    if (args != null) {
      for (final entry in args.entries) {
        value = value.replaceAll('{${entry.key}}', entry.value);
      }
    }
    return value;
  }

  String get languageName => language.nativeName;

  String policyStatus(PolicyStatus status) => tr('status.${status.name}');

  String paymentStatus(PaymentStatus status) => tr('status.${status.name}');

  String claimStatus(ClaimStatus status) => switch (status) {
    ClaimStatus.submitted => tr('status.submitted'),
    ClaimStatus.underReview => tr('status.underReview'),
    ClaimStatus.approved => tr('status.approved'),
    ClaimStatus.rejected => tr('status.rejected'),
  };

  String claimType(ClaimType type) => tr('claimType.${type.name}');

  String category(InsuranceCategoryType category) =>
      tr('category.${category.name}');

  String quotationStatus(QuotationStatus status) =>
      tr('quotationStatus.${status.name}');

  String quotationStatusDescription(QuotationStatus status) =>
      tr('quotationStatus.${status.name}Description');

  String planLabel(int months) => months == 1
      ? tr('checkout.monthly')
      : tr('checkout.months', {'count': '$months'});

  String claimNextStepTitle(ClaimStatus status) => switch (status) {
    ClaimStatus.submitted => tr('claim.nextStepSubmitted'),
    ClaimStatus.underReview => tr('claim.nextStepUnderReview'),
    ClaimStatus.approved => tr('claim.nextStepApproved'),
    ClaimStatus.rejected => tr('claim.nextStepRejected'),
  };

  String claimNextStepBody(ClaimStatus status) => switch (status) {
    ClaimStatus.submitted => tr('claim.nextStepBodySubmitted'),
    ClaimStatus.underReview => tr('claim.nextStepBodyUnderReview'),
    ClaimStatus.approved => tr('claim.nextStepBodyApproved'),
    ClaimStatus.rejected => tr('claim.nextStepBodyRejected'),
  };

  String paymentMethodShort(PaymentMethod method) => switch (method) {
    PaymentMethod.card => tr('payment.methodCard'),
    PaymentMethod.bankTransfer => tr('payment.methodBank'),
    PaymentMethod.eWallet => tr('payment.methodWallet'),
  };

  String paymentMethodLabel(PaymentMethod method) => switch (method) {
    PaymentMethod.card => tr('payment.card'),
    PaymentMethod.bankTransfer => tr('payment.bank'),
    PaymentMethod.eWallet => tr('payment.wallet'),
  };

  String activePoliciesCount(int count) =>
      tr('home.activePoliciesCount', {'count': '$count'});

  String dueCount(int count) => tr('home.dueNow', {'count': '$count'});

  String formatDate(DateTime value) =>
      isKhmer ? AppFormatters.dateKhmer(value) : AppFormatters.date(value);

  String formatDateShort(DateTime value) => isKhmer
      ? AppFormatters.dateShortKhmer(value)
      : AppFormatters.dateShort(value);

  String formatMonthYear(DateTime value) => isKhmer
      ? '${AppFormatters.khmerMonths[value.month - 1]} ${value.year}'
      : AppFormatters.monthYear(value);

  String monthAbbr(DateTime value) => isKhmer
      ? AppFormatters.monthKhmer(value)
      : AppFormatters.monthYear(value).substring(0, 3);

  String daysUntil(DateTime target) {
    final now = DateTime.now();
    final diff = DateTime(
      target.year,
      target.month,
      target.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return tr('payment.dueToday');
    if (diff < 0) {
      final days = diff.abs();
      return days == 1
          ? tr('payment.overdueOne')
          : tr('payment.overdueDays', {'count': '$days'});
    }
    return diff == 1
        ? tr('payment.dueInOne')
        : tr('payment.dueInDays', {'count': '$diff'});
  }

  static Map<AppLanguage, Map<String, String>> get _strings => const {
    AppLanguage.english: stringsEn,
    AppLanguage.khmer: stringsKm,
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(
      AppLocalizations(AppLanguage.fromCode(locale.languageCode)),
    );
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n {
    return Localizations.of<AppLocalizations>(this, AppLocalizations) ??
        const AppLocalizations(AppLanguage.english);
  }
}
