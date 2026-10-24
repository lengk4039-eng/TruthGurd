import 'package:flutter/material.dart';

/// Shared color tokens — keep in sync with `design/palette.md` at the repo root.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6E56F8);
  static const Color primaryDark = Color(0xFF4B32C8);
  static const Color primaryLight = Color(0xFFA796FF);
  static const Color accent = Color(0xFFF6A93B);

  static const List<Color> tileGradient = [
    Color(0xFF8A63F6),
    Color(0xFF5B34D9),
  ];
  static const List<Color> heroGradient = [
    Color(0xFF7C5CFA),
    Color(0xFF5733D8),
  ];
  static const List<Color> policyGradient = [
    Color(0xFF5F8BFF),
    Color(0xFF6849E8),
  ];
  static const List<Color> softGradient = [
    Color(0xFFF0EBFF),
    Color(0xFFFBFAFF),
  ];

  // Semantic
  static const Color success = Color(0xFF17B583);
  static const Color warning = Color(0xFFF0A128);
  static const Color error = Color(0xFFED5A5A);
  static const Color info = Color(0xFF4285F4);

  // Light surface
  static const Color backgroundLight = Color(0xFFF7F5FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFECE8F5);
  static const Color textPrimaryLight = Color(0xFF1B1730);
  static const Color textMutedLight = Color(0xFF706A85);

  // Dark surface
  static const Color backgroundDark = Color(0xFF121016);
  static const Color surfaceDark = Color(0xFF1B1822);
  static const Color borderDark = Color(0xFF2C2836);
  static const Color textPrimaryDark = Color(0xFFEDEBF2);
  static const Color textMutedDark = Color(0xFF9B96A8);

  /// Status → color, used by [StatusBadge] for policy/payment states.
  static Color forStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'PAID':
      case 'QUOTED':
      case 'ACCEPTED':
      case 'APPROVED':
        return success;
      case 'PENDING':
      case 'PROCESSING':
      case 'DUE_SOON':
      case 'SUBMITTED':
      case 'UNDER REVIEW':
        return warning;
      case 'EXPIRED':
      case 'OVERDUE':
      case 'CANCELLED':
      case 'FAILED':
      case 'REJECTED':
        return error;
      default:
        return info;
    }
  }
}
