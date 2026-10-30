import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared color tokens for the "Bright Blue Aurora" glass system.
///
/// Identity is cyan -> aurora blue -> deep azure, with a single violet step for
/// the outer edge of a gradient. Turquoise and green are deliberately absent:
/// `success` is the only green in the system and it never doubles as chrome.
///
/// Existing member names are kept stable because ~250 call sites resolve
/// colours through them; only the values changed.
class AppColors {
  AppColors._();

  // Brand — electric cyan. `primary` is reserved for the main CTA, the glowing
  // active nav disc and the aurora itself; do not spend it on decorative
  // surfaces. It is a light hue (L .57), so it only ever carries dark ink.
  static const Color primary = Color(0xFF00D9FF);
  static const Color primaryLight = Color(0xFF00F0FF);

  /// The deep end of the brand: azure. This is what the brand looks like *as*
  /// text, an icon or a hairline on a light surface — 5.2:1 on white, where
  /// `primary` manages only 1.7:1.
  static const Color primaryDark = Color(0xFF2563EB);

  /// Ink for content sitting directly on `primary` or the cyan steps. White on
  /// `#00D9FF` is 1.7:1, so bright brand fills always pair with this navy.
  static const Color onPrimary = Color(0xFF071F2B);

  /// The steps the aurora blends through: `primary` -> aurora blue -> deep
  /// azure, with a violet tip and an ice pale so the ribbons keep a shadow.
  static const Color auroraBlue = Color(0xFF168BFF);
  static const Color auroraViolet = Color(0xFF6366F1);
  static const Color auroraIce = Color(0xFFE8F8FC);
  static const Color auroraDeep = Color(0xFF0B303A);

  /// Gold, used only to lift the avatar stack and key-policy highlights.
  static const Color accent = Color(0xFFFFC24B);

  /// Bright end of the brand ramp, for the aurora cards that ride on light.
  static const Color softAuroraBlue = Color(0xFF60A5FA);

  /// The ramp the featured cover cards are painted with, brightest first.
  /// Card text always sits on the cyan end, so the stops below are the ones
  /// [onAurora] and friends were measured against — do not reorder or deepen
  /// them without re-inking the carousel.
  static const List<Color> auroraRamp = [
    Color(0xFF00F5FF),
    primary,
    auroraBlue,
    primaryDark,
  ];

  /// [auroraRamp] as a card fill. The stops stay partly transparent because a
  /// fully opaque ramp would hide the blurred backdrop, and the blur is what
  /// keeps the colour reading as glass rather than as a printed swatch.
  static Gradient auroraFill({
    Alignment begin = Alignment.bottomLeft,
    Alignment end = Alignment.topRight,
    List<double>? stops,
  }) => LinearGradient(
    begin: begin,
    end: end,
    stops: stops,
    colors: [for (final c in auroraRamp) c.withValues(alpha: 0.94)],
  );

  /// Ink for content sitting on an [auroraRamp] surface: 8.75:1 on `primary`,
  /// still 4.4:1 where the ramp reaches aurora blue.
  static const Color onAurora = Color(0xFF062B3A);

  /// Body copy on the same ramp — clears 4.5:1 right up to the cyan stop, so
  /// it only ever belongs in the bright half of the card.
  static const Color onAuroraBody = Color(0xFF31566A);

  /// Secondary labels on the ramp, above the 3:1 bar for non-text.
  static const Color onAuroraMuted = Color(0xFF416579);

  /// The legacy hero tiles keep white content across their whole surface, so
  /// both stops stay dark enough for it (5.2:1 at the light end).
  static const List<Color> tileGradient = [auroraDeep, primaryDark];
  static const List<Color> heroGradient = [
    Color(0xFF071F2B),
    Color(0xFF0B303A),
  ];
  static const List<Color> policyGradient = [primaryDark, auroraDeep];
  static const List<Color> softGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFE8F8FC),
  ];

  // Semantic
  /// Green, deliberately far enough from the cyan brand that a "paid" badge
  /// can never be mistaken for brand chrome.
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF5A524);
  static const Color error = Color(0xFFFF5757);
  static const Color info = primaryDark;

  /// Count bubbles and alert badges. Shares `error`'s red deliberately, but is
  /// named separately so a notification dot never gets restyled by accident.
  static const Color alert = error;

  // Light surface — icy blue-white, never warm-grey
  static const Color backgroundLight = Color(0xFFF3FCFF);
  static const Color backdropInnerLight = Color(0xFFFFFFFF);
  static const Color backdropOuterLight = Color(0xFFE8F8FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFD2ECF7);
  static const Color textPrimaryLight = Color(0xFF071F2B);
  static const Color textMutedLight = Color(0xFF5B7280);

  // Dark surface — navy night, same glass language. Kept a step darker than
  // `glassDark` so a dark card still reads as a plane above the page.
  static const Color backgroundDark = Color(0xFF020F18);
  static const Color backdropInnerDark = Color(0xFF0B2536);
  static const Color backdropOuterDark = Color(0xFF010810);
  static const Color surfaceDark = Color(0xFF0C2C3E);
  static const Color borderDark = Color(0xFF1B4560);
  static const Color textPrimaryDark = Color(0xFFEAF6FD);
  static const Color textMutedDark = Color(0xFF9DBAD0);

  // Glass surfaces
  static const Color glassDark = Color(0xE6102E42);
  static const Color glassDarkDeep = Color(0xF0071F2B);

  /// Light-mode glass. A card's own drop shadow falls *behind* its body, so any
  /// real transparency lets that shadow read back through the face as grey —
  /// this stop is deliberately near-opaque to keep light surfaces white.
  static const Color glassLight = Color(0xF7FFFFFF);
  static const Color glassLightSoft = Color(0xD9FFFFFF);

  /// The thin sheen across the top of every dark card.
  static const Color glassReflection = Color(0x14FFFFFF);

  /// 1px hairline used on all floating surfaces — low-opacity white reads as
  /// a lit edge rather than a drawn border.
  static const Color hairlineLight = Color(0x26FFFFFF);
  static const Color hairlineDark = Color(0x1AFFFFFF);

  /// Inner glow that separates a card from the backdrop it floats on.
  static const Color innerGlowLight = Color(0x1FFFFFFF);
  static const Color innerGlowDark = Color(0x14FFFFFF);

  /// The brand as a glyph on a surface the widget cannot see.
  ///
  /// `primary` is 1.7:1 on white, so a cyan icon looks broken on a light card
  /// and `primaryDark` is only 2.7:1 on navy glass. Aurora blue clears the 3:1
  /// bar for non-text content on both (3.4 light, 4.1 dark), which is what an
  /// icon needs; [brandOn] remains the right answer where the surface is known
  /// and the mark is text.
  static const Color brandInk = auroraBlue;

  /// Status → color, used by [StatusBadge] for policy/payment states.
  static Color forStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'PAID':
      case 'QUOTED':
      case 'ACCEPTED':
      case 'APPROVED':
      case 'VERIFIED':
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

  /// WCAG contrast between two colours (alpha is ignored, as in the spec).
  static double contrastRatio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Ink for content sitting *on* a filled [color]. White collapses on the
  /// brighter brand and status hues, so the fill decides which ink it gets.
  static Color inkOn(Color fill) =>
      fill.computeLuminance() > 0.40 ? onPrimary : Colors.white;

  /// The brand used *as* text or an icon: cyan only carries enough contrast on
  /// dark glass, so light surfaces get the azure end.
  static Color brandOn({required bool onDark}) =>
      onDark ? primary : primaryDark;

  /// [hue] pushed toward black (on light) or white (on dark) until it clears
  /// 4.5:1 as text. Status hues are tuned for fills, not for type.
  static Color legibleHue(Color hue, {required bool onDark}) {
    final background = onDark ? glassDark : surfaceLight;
    final anchor = onDark ? Colors.white : Colors.black;
    var out = hue;
    for (var i = 0; i < 10 && contrastRatio(out, background) < 4.5; i++) {
      out = Color.lerp(out, anchor, 0.2)!;
    }
    return out;
  }
}
