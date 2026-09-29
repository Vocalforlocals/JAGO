import 'package:flutter_test/flutter_test.dart';
import 'package:jago/main.dart';

void main() {
  testWidgets('JAGO App launch smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JagoApp());
    await tester.pumpAndSettle();

    // Verify JAGO title and official branding appears
    expect(find.text('JAGO'), findsWidgets);
    expect(find.textContaining('Janjatiya Awareness & Guidance for Opportunities'), findsWidgets);
    expect(find.text('Student Login'), findsOneWidget);
  });
}
