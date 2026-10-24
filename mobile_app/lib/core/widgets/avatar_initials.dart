import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../network/api_config.dart';
import '../theme/app_colors.dart';

class AvatarInitials extends StatelessWidget {
  final String initials;
  final double size;
  final String? imageUrl;
  final Uint8List? imageBytes;

  const AvatarInitials({
    super.key,
    required this.initials,
    this.size = 44,
    this.imageUrl,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Text(
      initials,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: size * 0.36,
      ),
    );

    Widget child = fallback;
    if (imageBytes != null) {
      child = Image.memory(
        imageBytes!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      child = Image.network(
        ApiConfig.resolveAssetUrl(imageUrl!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: AppColors.tileGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
