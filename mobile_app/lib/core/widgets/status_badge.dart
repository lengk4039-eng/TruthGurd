import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Small colored pill for a policy/payment status ("Active", "Overdue", ...).
/// Color comes from [AppColors.forStatus] so the same word always reads the
/// same way everywhere in the app.
class StatusBadge extends StatelessWidget {
  final String label;
  final bool subtle;
  final Color? color;

  const StatusBadge({
    super.key,
    required this.label,
    this.subtle = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = color ?? AppColors.forStatus(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: subtle ? statusColor.withValues(alpha: 0.12) : statusColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: subtle ? statusColor : Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: subtle ? statusColor : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
