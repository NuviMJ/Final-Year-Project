import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qolguard/app.dart';

void main() {
  testWidgets('app renders and shows the three QoL risk categories',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: QoLGuardApp()));

    expect(find.text('QoLGuard'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });
}
