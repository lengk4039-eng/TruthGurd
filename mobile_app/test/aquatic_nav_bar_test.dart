import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trustguard_insurance/core/theme/app_colors.dart';
import 'package:trustguard_insurance/core/widgets/glass/aquatic_nav_bar.dart';
import 'package:trustguard_insurance/core/widgets/glass/glass_icon.dart';

const _left = [
  NavTab(kind: GlassIconKind.house, label: 'Home', branch: 0),
  NavTab(kind: GlassIconKind.shield, label: 'Policies', branch: 1),
];
const _right = [
  NavTab(kind: GlassIconKind.wallet, label: 'Payments', branch: 2),
  NavTab(kind: GlassIconKind.person, label: 'Account', branch: 3),
];
const _center = NavTab(kind: GlassIconKind.bag, label: 'Buy', branch: 4);
const _labels = ['Home', 'Policies', 'Buy', 'Payments', 'Account'];

Widget _bar(int? active, {ValueChanged<NavTab>? onSelect}) => MaterialApp(
  home: Scaffold(
    body: Align(
      alignment: Alignment.bottomCenter,
      child: AquaticNavBar(
        leftTabs: _left,
        rightTabs: _right,
        center: _center,
        activeBranch: active,
        onSelect: onSelect ?? (_) {},
      ),
    ),
  ),
);

/// The disc behind a tab's icon, read off the decoration it animates: alpha 1
/// means fully lit, 0 means the tab is dark. [AnimatedContainer] rebuilds an
/// inner [Container] with the lerped decoration every frame, so that is where
/// a mid-animation value lives — the AnimatedContainer itself only holds the
/// target it is heading for.
BoxDecoration _disc(WidgetTester tester, String label) => _discUnder(
  tester,
  find.descendant(
    of: find.widgetWithText(Column, label),
    matching: find.byType(AnimatedContainer),
  ),
);

BoxDecoration _discUnder(WidgetTester tester, Finder animated) {
  expect(animated, findsOneWidget);
  final live = find.descendant(of: animated, matching: find.byType(Container));
  // The outermost Container is the one AnimatedContainer just rebuilt; deeper
  // ones belong to the glyph.
  return tester.widget<Container>(live.first).decoration! as BoxDecoration;
}

double _lit(WidgetTester tester, String label) =>
    (_disc(tester, label).gradient! as RadialGradient).colors[1].a;

Color? _glyphInk(WidgetTester tester, String label) {
  final found = find.descendant(
    of: find.widgetWithText(Column, label),
    matching: find.byType(GlassIcon),
  );
  expect(found, findsOneWidget, reason: 'no glyph under tab "$label"');
  return tester.widget<GlassIcon>(found).mono;
}

void main() {
  testWidgets('all five tabs sit in one row with identical discs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_bar(0));
    await tester.pumpAndSettle();

    // No raised centre button any more: the bar is exactly one bar tall.
    expect(
      tester.getSize(find.byType(AquaticNavBar)).height,
      AquaticNavBar.barHeight,
    );

    final discs = find.byType(AnimatedContainer);
    expect(discs, findsNWidgets(5));
    final rects = [for (var i = 0; i < 5; i++) tester.getRect(discs.at(i))];
    for (final rect in rects) {
      expect(rect.size, const Size(40, 40));
      expect(
        rect.center.dy,
        rects.first.center.dy,
        reason: 'every icon shares the same vertical position',
      );
    }
    for (var i = 1; i < rects.length; i++) {
      expect(
        rects[i].center.dx,
        greaterThan(rects[i - 1].center.dx),
        reason: 'tabs are laid out left to right, none overlapping',
      );
    }
  });

  testWidgets('only the active tab is lit, and the centre is no exception', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_bar(1));
    await tester.pumpAndSettle();

    expect(_lit(tester, 'Policies'), 1.0);
    expect(_disc(tester, 'Policies').boxShadow, isNotEmpty);
    for (final dark in ['Home', 'Buy', 'Payments', 'Account']) {
      expect(_lit(tester, dark), 0.0, reason: '$dark should not glow');
      expect(_disc(tester, dark).boxShadow, isEmpty);
    }

    // Activating the centre moves the disc to it and nowhere else.
    await tester.pumpWidget(_bar(4));
    await tester.pumpAndSettle();
    expect(_lit(tester, 'Buy'), 1.0);
    expect(_disc(tester, 'Buy').boxShadow, isNotEmpty);
    for (final dark in _labels.where((l) => l != 'Buy')) {
      expect(_lit(tester, dark), 0.0, reason: '$dark should not glow');
    }
  });

  testWidgets('the glow fades to the new tab instead of popping', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_bar(1));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_bar(2));
    await tester.pump(const Duration(milliseconds: 110));

    expect(_lit(tester, 'Payments'), greaterThan(0.0));
    expect(_lit(tester, 'Payments'), lessThan(1.0));
    expect(_lit(tester, 'Policies'), greaterThan(0.0));

    await tester.pumpAndSettle();
    expect(_lit(tester, 'Payments'), 1.0);
    expect(_lit(tester, 'Policies'), 0.0);
  });

  testWidgets('the selected glyph takes the ink that reads on the disc', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_bar(4));
    await tester.pumpAndSettle();

    expect(_glyphInk(tester, 'Buy'), AppColors.onPrimary);
    expect(_glyphInk(tester, 'Home'), AppColors.textMutedLight);

    // The disc is bright at its core, so white ink would fail here.
    expect(
      AppColors.contrastRatio(AppColors.onPrimary, AppColors.primary),
      greaterThan(4.5),
    );
  });

  testWidgets('tapping any tab, including the centre, reports that tab', (
    WidgetTester tester,
  ) async {
    NavTab? tapped;
    await tester.pumpWidget(_bar(0, onSelect: (tab) => tapped = tab));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(Column, 'Payments'));
    await tester.pumpAndSettle();
    expect(tapped?.branch, 2);

    await tester.tap(find.widgetWithText(Column, 'Buy'));
    await tester.pumpAndSettle();
    expect(tapped?.branch, 4);
  });
}
