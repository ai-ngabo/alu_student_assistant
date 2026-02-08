// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:alu_student_assistant/app.dart';

void main() {
  testWidgets('Bottom navigation switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const AluStudentAssistantApp());

    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.text('Assignments'));
    await tester.pumpAndSettle();
    expect(find.text('Assignments'), findsNWidgets(2));

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsNWidgets(2));

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsNWidgets(2));
  });
}
