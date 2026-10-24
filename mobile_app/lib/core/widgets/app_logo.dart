import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// The TrustGuard mark, optionally paired with the wordmark lock-up.
/// Backed by `assets/logo/trustguard_mark.svg` so swapping the final logo
/// (once picked) only means replacing that one file.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;

  const AppLogo({super.key, this.size = 40, this.showWordmark = false, this.wordmarkColor});

  @override
  Widget build(BuildContext context) {
    final mark = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: SvgPicture.asset('assets/logo/trustguard_mark.svg', width: size, height: size),
    );
    if (!showWordmark) return mark;

    final textColor = wordmarkColor ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TrustGuard',
              style: GoogleFonts.poppins(fontSize: size * 0.38, fontWeight: FontWeight.w600, color: textColor, height: 1),
            ),
            Text(
              'INSURANCE',
              style: GoogleFonts.inter(
                fontSize: size * 0.16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
