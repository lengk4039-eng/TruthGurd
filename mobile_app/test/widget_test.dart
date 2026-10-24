import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trustguard_insurance/main.dart';

void main() {
  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrustGuardApp()));

    expect(find.text('TrustGuard'), findsOneWidget);
    expect(find.text('Protection you can trust'), findsOneWidget);
  });
}
