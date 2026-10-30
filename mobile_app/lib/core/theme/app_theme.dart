import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

/// Light and dark [ThemeData] built from the shared design tokens in
/// [AppColors]. Poppins/Inter carry English text, Noto Sans Khmer carries
/// Khmer so the taller glyphs never clip.
class AppTheme {
  AppTheme._();

  static TextStyle _heading({
    required double size,
    required FontWeight weight,
    required Color color,
    required bool khmer,
    double? height,
  }) {
    if (khmer) {
      return GoogleFonts.notoSansKhmer(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height ?? 1.45,
      );
    }
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  static TextStyle _body({
    required double size,
    required FontWeight weight,
    required Color color,
    required bool khmer,
    double? height,
    double? letterSpacing,
  }) {
    if (khmer) {
      return GoogleFonts.notoSansKhmer(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height == null ? null : height + 0.12,
        letterSpacing: 0,
      );
    }
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme _textTheme(Color primaryText, Color mutedText, bool khmer) {
    final base =
        (khmer
                ? GoogleFonts.notoSansKhmerTextTheme()
                : GoogleFonts.interTextTheme())
            .apply(bodyColor: primaryText, displayColor: primaryText);
    return base.copyWith(
      displayLarge: _heading(
        size: 40,
        weight: FontWeight.w700,
        color: primaryText,
        khmer: khmer,
        height: 1.2,
      ),
      displayMedium: _heading(
        size: 32,
        weight: FontWeight.w700,
        color: primaryText,
        khmer: khmer,
        height: 1.25,
      ),
      headlineLarge: _heading(
        size: 28,
        weight: FontWeight.w700,
        color: primaryText,
        khmer: khmer,
        height: 1.3,
      ),
      headlineMedium: _heading(
        size: 24,
        weight: FontWeight.w700,
        color: primaryText,
        khmer: khmer,
        height: 1.3,
      ),
      headlineSmall: _heading(
        size: 20,
        weight: FontWeight.w700,
        color: primaryText,
        khmer: khmer,
        height: 1.35,
      ),
      titleLarge: _heading(
        size: 18,
        weight: FontWeight.w700,
        color: primaryText,
        khmer: khmer,
      ),
      titleMedium: _heading(
        size: 16,
        weight: FontWeight.w600,
        color: primaryText,
        khmer: khmer,
      ),
      titleSmall: _heading(
        size: 14,
        weight: FontWeight.w600,
        color: primaryText,
        khmer: khmer,
      ),
      bodyLarge: _body(
        size: 16,
        weight: FontWeight.w400,
        color: primaryText,
        khmer: khmer,
        height: 1.5,
      ),
      bodyMedium: _body(
        size: 14,
        weight: FontWeight.w400,
        color: primaryText,
        khmer: khmer,
        height: 1.5,
      ),
      bodySmall: _body(
        size: 12.5,
        weight: FontWeight.w400,
        color: mutedText,
        khmer: khmer,
        height: 1.4,
      ),
      labelLarge: _body(
        size: 14,
        weight: FontWeight.w600,
        color: primaryText,
        khmer: khmer,
      ),
      labelMedium: _body(
        size: 12,
        weight: FontWeight.w600,
        color: mutedText,
        khmer: khmer,
        letterSpacing: 0.2,
      ),
      labelSmall: _body(
        size: 11,
        weight: FontWeight.w600,
        color: mutedText,
        khmer: khmer,
        letterSpacing: 0.3,
      ),
    );
  }

  static final ThemeData light = _build(
    brightness: Brightness.light,
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    border: AppColors.borderLight,
    textPrimary: AppColors.textPrimaryLight,
    textMuted: AppColors.textMutedLight,
    khmer: false,
  );

  static final ThemeData lightKhmer = _build(
    brightness: Brightness.light,
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    border: AppColors.borderLight,
    textPrimary: AppColors.textPrimaryLight,
    textMuted: AppColors.textMutedLight,
    khmer: true,
  );

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    border: AppColors.borderDark,
    textPrimary: AppColors.textPrimaryDark,
    textMuted: AppColors.textMutedDark,
    khmer: false,
  );

  static final ThemeData darkKhmer = _build(
    brightness: Brightness.dark,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    border: AppColors.borderDark,
    textPrimary: AppColors.textPrimaryDark,
    textMuted: AppColors.textMutedDark,
    khmer: true,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textMuted,
    required bool khmer,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.accent,
      onSecondary: AppColors.onPrimary,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: isDark
          ? AppColors.surfaceDark
          : AppColors.backdropOuterLight,
      outline: border,
    );

    final textTheme = _textTheme(textPrimary, textMuted, khmer);

    /// `primary` is far too light to serve as text or icon colour on a light
    /// page (2:1), so anything painted *as* the brand uses the dark end.
    final brandText = AppColors.brandOn(onDark: isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      fontFamily: khmer
          ? GoogleFonts.notoSansKhmer().fontFamily
          : GoogleFonts.inter().fontFamily,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 4,
        titleTextStyle: _heading(
          size: 19,
          weight: FontWeight.w700,
          color: textPrimary,
          khmer: khmer,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 1,
        shadowColor: isDark
            ? Colors.black.withValues(alpha: 0.45)
            : AppColors.primaryDark.withValues(alpha: 0.10),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: border.withValues(alpha: isDark ? 1 : 0.75)),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: _body(
            size: 14.5,
            weight: FontWeight.w600,
            color: colorScheme.onPrimary,
            khmer: khmer,
          ),
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: _body(
            size: 15,
            weight: FontWeight.w600,
            color: colorScheme.onPrimary,
            khmer: khmer,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandText,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: _body(
            size: 15,
            weight: FontWeight.w600,
            color: brandText,
            khmer: khmer,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandText,
          textStyle: _body(
            size: 14,
            weight: FontWeight.w600,
            color: brandText,
            khmer: khmer,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        hintStyle: _body(
          size: 14.5,
          weight: FontWeight.w400,
          color: textMuted,
          khmer: khmer,
        ),
        labelStyle: _body(
          size: 14.5,
          weight: FontWeight.w400,
          color: textMuted,
          khmer: khmer,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: brandText, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.backdropOuterLight.withValues(alpha: 0.6),
        selectedColor: colorScheme.primary,
        labelStyle: _body(
          size: 13,
          weight: FontWeight.w600,
          color: textPrimary,
          khmer: khmer,
        ),
        secondaryLabelStyle: _body(
          size: 13,
          weight: FontWeight.w600,
          color: AppColors.onPrimary,
          khmer: khmer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: BorderSide.none,
        ),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.13),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return _body(
            size: 11.5,
            weight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? brandText : textMuted,
            khmer: khmer,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? brandText : textMuted,
            size: 23,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brandText,
        linearTrackColor: border,
        circularTrackColor: border,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: _heading(
          size: 19,
          weight: FontWeight.w700,
          color: textPrimary,
          khmer: khmer,
        ),
        contentTextStyle: _body(
          size: 14,
          weight: FontWeight.w400,
          color: textMuted,
          khmer: khmer,
          height: 1.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: _body(
          size: 14,
          weight: FontWeight.w400,
          color: background,
          khmer: khmer,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: brandText,
        titleTextStyle: _body(
          size: 14.5,
          weight: FontWeight.w500,
          color: textPrimary,
          khmer: khmer,
        ),
        subtitleTextStyle: _body(
          size: 12.5,
          weight: FontWeight.w400,
          color: textMuted,
          khmer: khmer,
        ),
      ),
    );
  }
}
