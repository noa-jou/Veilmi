import 'package:flutter_test/flutter_test.dart';
import 'package:veilmi/main.dart';
import 'package:flutter/material.dart';

// This file is a widget test.
// A widget test is a test that opens the Flutter UI and checks what is visible on screen.
//
// For a beginner:
// - we create the app in a test environment,
// - we wait for the UI to finish building,
// - then we check whether important text is shown.
// If the expected text is missing, the test fails.
void main() {
  // This test checks that the app starts successfully and shows the main screen.
  // It is a simple smoke test: the app should not crash and should display the main labels.
  testWidgets('Veilmi app loads', (WidgetTester tester) async {
    // Build the app with English as the starting language.
    // This is useful because the test should not depend on a saved user setting.
    await tester.pumpWidget(const VeilmiApp(initialLocale: Locale('en')));

    // Wait for the UI to finish all animations and rebuilds.
    await tester.pumpAndSettle();

    // These are the texts we expect to see on the main screen.
    // If the app has changed its layout or text, this test will catch it.
    expect(find.text('Veilmi'), findsOneWidget);
    expect(find.text('Encrypt'), findsOneWidget);
    expect(find.text('Decrypt'), findsOneWidget);
  });
}
