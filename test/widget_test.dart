import 'package:flutter_test/flutter_test.dart';
import 'package:aniverse_explorer/main.dart';

void main() {
  testWidgets('ShoppingHub smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ShoppingHubApp());
  });
}
