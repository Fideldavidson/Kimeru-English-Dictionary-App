// Basic smoke test for the Kimeru Dictionary app.

import 'package:flutter_test/flutter_test.dart';
import 'package:kimeru_mobile/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KimeruDictionaryApp());
    // Verify the app builds without errors
    expect(find.text('Kimeru Dictionary'), findsWidgets);
  });
}
