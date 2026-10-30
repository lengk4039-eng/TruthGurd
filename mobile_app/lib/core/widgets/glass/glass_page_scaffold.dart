import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../localization/app_localizations.dart';
import '../../theme/app_dimens.dart';
import 'app_backdrop.dart';
import 'glass_page_header.dart';

/// The frame for a pushed (non-tab) screen.
///
/// A tab screen inherits the backdrop from the shell; a pushed route paints
/// over the theme's flat background, and glass over a flat background has
/// nothing to blur. So this owns its own [AppBackdrop] and keeps the aurora
/// wash behind the cards.
class GlassPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  /// The scrollable the caller supplies (a [ListView], [CustomScrollView]...).
  /// It is laid out under the header, so pull-to-refresh still works.
  final Widget child;
  final EdgeInsets padding;

  const GlassPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      0,
      AppSpacing.lg,
      AppSpacing.xxl,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return AppBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: GlassPageHeader(
                  title: title,
                  subtitle: subtitle,
                  leading: const GlassBackButton(),
                  actions: actions,
                ),
              ),
              Expanded(
                child: Padding(padding: padding, child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [AppBackButton]'s glass twin: a frosted disc rather than a tinted square,
/// so the control matches the cards it sits above.
class GlassBackButton extends StatelessWidget {
  const GlassBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassIconButton(
      icon: Icons.arrow_back_rounded,
      tooltip: context.l10n.tr('common.back'),
      onTap: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          context.go('/home');
        }
      },
    );
  }
}
