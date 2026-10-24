import 'package:flutter/material.dart';

/// Shared color tokens — keep in sync with `design/palette.md` at the repo root.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color accent = Color(0xFFF59E0B);

  static const List<Color> tileGradient = [Color(0xFF8B5CF6), Color(0xFF6D28D9)];

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Light surface
  static const Color backgroundLight = Color(0xFFF8F7FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE4E1EB);
  static const Color textPrimaryLight = Color(0xFF1D1A24);
  static const Color textMutedLight = Color(0xFF6B6675);

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
