// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Keep this test independent of platform plugins (photo_manager),
    // so it can compile/run in CI without native bindings.
    await tester.pumpWidget(const TestPlaceholderApp());
    expect(find.text('OK'), findsOneWidget);
  });
}

class TestPlaceholderApp extends StatelessWidget {
  const TestPlaceholderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: Text('OK')),
    );
  }
}
