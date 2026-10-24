import 'package:flutter_test/flutter_test.dart';
import 'package:clean_quest/main.dart';

void main() {
  testWidgets('Terra Scout smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TerraScoutApp());
    expect(find.text('TERRA SCOUT // OPS ACTIVE'), findsOneWidget);
  });
}
