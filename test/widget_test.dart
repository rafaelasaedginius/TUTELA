import 'package:flutter_test/flutter_test.dart';

import 'package:tutela/main.dart';

void main() {
  testWidgets('shows splash message', (WidgetTester tester) async {
    await tester.pumpWidget(const TutelaApp());

    expect(find.text('Tutela,'), findsOneWidget);
    expect(find.text('is with you'), findsOneWidget);
  });

  testWidgets('navigates to getting started screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TutelaApp());
    await tester.pump(const Duration(milliseconds: 3800));
    await tester.pumpAndSettle();

    expect(find.text('Getting started'), findsOneWidget);
    expect(find.text('Move through the city with confidence.'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.textContaining('Create an Account.'), findsOneWidget);
  });
}
