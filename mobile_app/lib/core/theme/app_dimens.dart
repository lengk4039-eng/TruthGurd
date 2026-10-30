import 'package:flutter/painting.dart';

/// Shared spacing/radius scale so every screen lines up on the same grid.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();

  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double hero = 28;
  static const double nav = 34;
  static const double pill = 999;
}

/// Backdrop blur strengths. The glass spec caps out at 30 — anything higher
/// and the card stops reading as translucent and becomes a wall.
class AppBlur {
  AppBlur._();

  static const double soft = 15;
  static const double medium = 22;
  static const double strong = 30;
}

/// The two-layer elevation rule: a tight *contact* shadow anchors the card and
/// a wide *ambient* shadow lifts it off the backdrop. Always emit both — a
/// single shadow is what makes the current UI look flat.
class AppShadow {
  AppShadow._();

  /// [lift] scales the ambient spread: 1 = resting card, 2 = floating hero,
  /// 3 = modal/sheet sitting above everything.
  static List<BoxShadow> shadow({required bool isDark, double lift = 1}) {
    final contact = isDark
        ? const _Pair(Color(0x59000000), 10, 3)
        : const _Pair(Color(0x1A0A2438), 8, 2);
    final ambient = isDark
        ? const _Pair(Color(0x73000000), 40, 16)
        : const _Pair(Color(0x240A2A45), 32, 12);
    return [
      contact._toShadow(spread: -2),
      ambient._toShadow(spread: -6, scale: lift),
    ];
  }

  /// Coloured halo for the primary CTA and the active nav tab's disc.
  static List<BoxShadow> glow(
    Color color, {
    double radius = 24,
    double y = 10,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.45),
        blurRadius: radius,
        offset: Offset(0, y),
        spreadRadius: -4,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.22),
        blurRadius: radius * 2,
        offset: Offset(0, y * 1.6),
        spreadRadius: 2,
      ),
    ];
  }

  /// Hairline edge. On glass this is a lit rim, not a drawn outline.
  static const double hairlineWidth = 1;
}

class _Pair {
  final Color color;
  final double blur;
  final double y;
  const _Pair(this.color, this.blur, this.y);

  BoxShadow _toShadow({required double spread, double scale = 1}) {
    return BoxShadow(
      color: color,
      blurRadius: blur * scale,
      offset: Offset(0, y * scale),
      spreadRadius: spread,
    );
  }
}
