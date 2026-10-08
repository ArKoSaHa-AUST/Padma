import 'package:flutter_test/flutter_test.dart';
import 'package:padma/main.dart';

void main() {
  testWidgets('Padma app launches and shows Sign In screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PadmaApp());
    await tester.pumpAndSettle();

    expect(find.text('PADMA'), findsOneWidget);
    expect(find.text('Student Sign In'), findsOneWidget);
    expect(find.text('Enter Padma Transit'), findsOneWidget);
  });
}
