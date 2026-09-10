import 'package:flutter_test/flutter_test.dart';
import 'package:veilmi/main.dart';
import 'package:flutter/material.dart';

// This file contains a widget test.
// A widget test checks whether the Flutter UI renders correctly.
// In simple terms: it opens the app in a test environment and looks for visible text.
void main() {
  // This test makes sure the app can start and display the main screen.
  testWidgets('Veilmi app loads', (WidgetTester tester) async {
    // Build the app with English as the initial locale.
    await tester.pumpWidget(const VeilmiApp(initialLocale: Locale('en')));

    // Check that the expected text appears on the screen.
    // If these texts are not found, the test fails.
    expect(find.text('Veilmi'), findsOneWidget);
    expect(find.text('Encrypt'), findsOneWidget);
    expect(find.text('Decrypt'), findsOneWidget);
  });
}
