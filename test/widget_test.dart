import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_ia/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MuslimIAApp());
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Apprendre'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
