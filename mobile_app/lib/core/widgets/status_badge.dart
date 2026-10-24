import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Small colored pill for a policy/payment status ("Active", "Overdue", ...).
/// Color comes from [AppColors.forStatus] so the same word always reads the
/// same way everywhere in the app.
class StatusBadge extends StatelessWidget {
  final String label;
  final bool subtle;

  const StatusBadge({super.key, required this.label, this.subtle = true});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStatus(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: subtle ? color.withValues(alpha: 0.12) : color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: subtle ? color : Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: subtle ? color : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
