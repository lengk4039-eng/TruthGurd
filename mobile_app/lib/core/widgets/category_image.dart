import 'package:flutter/material.dart';

import '../models/insurance_category.dart';
import '../theme/app_colors.dart';

class CategoryImage extends StatelessWidget {
  final InsuranceCategoryType category;
  final double size;
  final double radius;
  final Color? borderColor;
  final double borderWidth;

  const CategoryImage({
    super.key,
    required this.category,
    this.size = 48,
    this.radius = 12,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
      ),
      child: Image.asset(
        category.imageAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            category.icon,
            color: AppColors.brandInk,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }
}
