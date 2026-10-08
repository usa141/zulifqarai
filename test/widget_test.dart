import 'package:flutter_test/flutter_test.dart';
import 'package:zulfiqar_ai/main.dart';

void main() {
  testWidgets('TradeJARVIS app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TradeJarvisApp());

    // Verify that TradeJARVIS title is present.
    expect(find.text('TradeJARVIS'), findsOneWidget);
  });
}
