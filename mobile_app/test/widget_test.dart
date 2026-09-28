import 'package:flutter_test/flutter_test.dart';
import 'package:jago/main.dart';

void main() {
  testWidgets('JAGO App launch smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JagoApp());
    await tester.pumpAndSettle();

    // Verify JAGO title appears
    expect(find.text('JAGO'), findsOneWidget);
    expect(find.text('Student Login'), findsOneWidget);
  });
}
