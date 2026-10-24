import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AvatarInitials extends StatelessWidget {
  final String initials;
  final double size;

  const AvatarInitials({super.key, required this.initials, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: AppColors.tileGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: size * 0.36),
      ),
    );
  }
}
