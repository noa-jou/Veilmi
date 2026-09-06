import 'package:flutter_test/flutter_test.dart';
import 'package:veilmi/main.dart';

void main() {
  testWidgets('Veilmi app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const VeilmiApp());

    expect(find.text('Veilmi'), findsOneWidget);
    expect(find.text('Encrypt'), findsOneWidget);
    expect(find.text('Decrypt'), findsOneWidget);
  });
}
