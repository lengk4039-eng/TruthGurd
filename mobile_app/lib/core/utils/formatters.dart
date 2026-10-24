import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  static final NumberFormat _currencyWhole = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  );
  static final DateFormat _date = DateFormat('MMM d, yyyy');
  static final DateFormat _dateShort = DateFormat('MMM d');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');

  static String currency(num value) => _currency.format(value);
  static String currencyWhole(num value) => _currencyWhole.format(value);
  static String date(DateTime value) => _date.format(value);
  static String dateShort(DateTime value) => _dateShort.format(value);
  static String monthYear(DateTime value) => _monthYear.format(value);

  static const List<String> khmerMonths = [
    'មករា',
    'កុម្ភៈ',
    'មីនា',
    'មេសា',
    'ឧសភា',
    'មិថុនា',
    'កក្កដា',
    'សីហា',
    'កញ្ញា',
    'តុលា',
    'វិច្ឆិកា',
    'ធ្នូ',
  ];

  static String dateKhmer(DateTime value) =>
      '${value.day} ${khmerMonths[value.month - 1]} ${value.year}';

  static String dateShortKhmer(DateTime value) =>
      '${value.day} ${khmerMonths[value.month - 1]}';

  static String monthKhmer(DateTime value) => khmerMonths[value.month - 1];

  static String daysUntil(DateTime target) {
    final now = DateTime.now();
    final diff = DateTime(
      target.year,
      target.month,
      target.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'Due today';
    if (diff < 0) {
      return '${diff.abs()} day${diff.abs() == 1 ? '' : 's'} overdue';
    }
    return 'Due in $diff day${diff == 1 ? '' : 's'}';
  }
}
