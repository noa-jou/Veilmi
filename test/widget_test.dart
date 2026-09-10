import 'package:flutter_test/flutter_test.dart';
import 'package:veilmi/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Veilmi app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const VeilmiApp(initialLocale: Locale('en')));

    expect(find.text('Veilmi'), findsOneWidget);
    expect(find.text('Encrypt'), findsOneWidget);
    expect(find.text('Decrypt'), findsOneWidget);
  });
}
