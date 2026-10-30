import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/insurance_category.dart';
import '../../models/insurance_package.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import 'glass_card.dart';
import 'glass_icon.dart';

/// Component A — the horizontal carousel of cover plans that anchors Home.
///
/// Each card rides the bright aurora ramp — cyan under the text, cooling to
/// electric blue behind the category photograph — so the plan reads as a real
/// product rather than a colour chip.
class FeatureCardCarousel extends StatelessWidget {
  final List<InsurancePackage> packages;
  final ValueChanged<InsurancePackage> onOpen;
  final ValueChanged<InsurancePackage> onApply;
  final double height;

  const FeatureCardCarousel({
    super.key,
    required this.packages,
    required this.onOpen,
    required this.onApply,
    this.height = 262,
  });

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: height,
      child: PageView.builder(
        padEnds: false,
        controller: PageController(viewportFraction: 0.88),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? AppSpacing.md : AppSpacing.sm,
              right: index == packages.length - 1 ? AppSpacing.md : 0,
            ),
            child: _FeatureCard(
              package: package,
              phase: _Aurora.phase(index),
              onOpen: () => onOpen(package),
              onApply: () => onApply(package),
            ),
          );
        },
      ),
    );
  }
}

/// The same ramp, angled and stopped slightly differently per card, so a
/// scrolled carousel reads as one family rather than one stamped shape. Every
/// phase keeps the deep electric-blue end in the top-right corner, because
/// that is where the photograph sits and the text never does.
typedef _AuroraPhase = ({
  Alignment begin,
  Alignment end,
  List<double> stops,
  Alignment glow,
});

class _Aurora {
  _Aurora._();

  static const _phases = <_AuroraPhase>[
    (
      begin: Alignment(-1.0, 1.0),
      end: Alignment(1.0, -1.0),
      stops: [0.0, 0.30, 0.72, 1.0],
      glow: Alignment(0.62, -0.58),
    ),
    (
      begin: Alignment(-1.0, 0.62),
      end: Alignment(0.86, -1.0),
      stops: [0.0, 0.38, 0.78, 1.0],
      glow: Alignment(0.74, -0.42),
    ),
    (
      begin: Alignment(-0.72, 1.0),
      end: Alignment(1.0, -0.78),
      stops: [0.0, 0.26, 0.68, 1.0],
      glow: Alignment(0.54, -0.68),
    ),
  ];

  static _AuroraPhase phase(int index) => _phases[index % _phases.length];

  static Gradient fill(_AuroraPhase p) =>
      AppColors.auroraFill(begin: p.begin, end: p.end, stops: p.stops);
}

class _FeatureCard extends StatelessWidget {
  final InsurancePackage package;
  final _AuroraPhase phase;
  final VoidCallback onOpen;
  final VoidCallback onApply;

  const _FeatureCard({
    required this.package,
    required this.phase,
    required this.onOpen,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlassCard(
      tone: GlassTone.frost,
      fill: _Aurora.fill(phase),
      onTap: onOpen,
      lift: 2,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Stack(
        children: [
          Positioned(
            top: -44,
            right: -34,
            width: 208,
            height: 190,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: phase.glow,
                    colors: [
                      Colors.white.withValues(alpha: 0.62),
                      AppColors.primary.withValues(alpha: 0.30),
                      AppColors.auroraBlue.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.48, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: -6,
            width: 132,
            height: 132,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.softAuroraBlue.withValues(alpha: 0.38),
                      AppColors.softAuroraBlue.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -16,
            right: -20,
            width: 158,
            height: 132,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => RadialGradient(
                center: phase.glow,
                radius: 1.18,
                colors: const [Color(0xF2000000), Colors.transparent],
                stops: const [0.30, 0.95],
              ).createShader(bounds),
              child: Image.asset(
                package.category.imageAsset,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          // The photograph's own aurora: cyan haze strongest where the image
          // dissolves, clear at its bright corner, so it belongs to the card
          // instead of sitting inside a rectangle.
          Positioned(
            top: -16,
            right: -20,
            width: 158,
            height: 132,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.46),
                      AppColors.primary.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GlassIcon(
                    kind: glyphForCategory(package.category),
                    size: 48,
                    bright: true,
                  ),
                  const Spacer(),
                  _RatingChip(rating: package.rating),
                ],
              ),
              const Spacer(),
              Text(
                package.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onAurora,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                package.tagline,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.onAuroraBody,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Price(monthlyPrice: package.monthlyPrice),
                  const Spacer(),
                  _PopularStack(reviewCount: package.reviewCount),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _ApplyPill(label: l10n.tr('home.apply'), onTap: onApply),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;
  const _RatingChip({required this.rating});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      tone: GlassTone.frost,
      blur: AppBlur.soft,
      lift: 0.6,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: AppColors.accent),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.onAurora,
            ),
          ),
        ],
      ),
    );
  }
}

class _Price extends StatelessWidget {
  final double monthlyPrice;
  const _Price({required this.monthlyPrice});

  static String _format(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '\$${_format(monthlyPrice)}',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.onAurora,
            height: 1,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          context.l10n.tr('home.perMonth'),
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.onAuroraMuted,
          ),
        ),
      ],
    );
  }
}

/// Social proof derived from the package's real review count. The discs are
/// anonymous on purpose — inventing named customers would be a lie, and the
/// count is the honest version of the same signal.
class _PopularStack extends StatelessWidget {
  final int reviewCount;
  const _PopularStack({required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    if (reviewCount <= 0) return const SizedBox.shrink();
    final label = reviewCount >= 1000
        ? '${(reviewCount / 1000).toStringAsFixed(1)}k'
        : '$reviewCount';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 26,
          width: 26 + 14,
          child: Stack(
            children: [
              for (var i = 0; i < 3; i++)
                Positioned(
                  left: i * 14,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryLight, AppColors.auroraBlue],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.82),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$label ${context.l10n.tr('home.insured')}',
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.onAurora,
          ),
        ),
      ],
    );
  }
}

class _ApplyPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ApplyPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      tone: GlassTone.frost,
      blur: AppBlur.soft,
      lift: 1.2,
      glow: AppColors.softAuroraBlue,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onAurora,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 15,
            color: AppColors.auroraBlue,
          ),
        ],
      ),
    );
  }
}
