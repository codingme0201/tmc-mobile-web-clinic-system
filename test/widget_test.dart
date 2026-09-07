import 'package:flutter_test/flutter_test.dart';
import 'package:carelink_mobile/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const CareLinkApp());
    expect(find.byType(CareLinkApp), findsOneWidget);
  });
}
