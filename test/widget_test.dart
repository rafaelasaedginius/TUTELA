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
    await _finishSplash(tester);

    expect(find.text('Getting started'), findsOneWidget);
    expect(find.text('Move through the city with confidence.'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.textContaining('Create an Account.'), findsOneWidget);
  });

  testWidgets('opens sign in screen from log in', (WidgetTester tester) async {
    await tester.pumpWidget(const TutelaApp());
    await _finishSplash(tester);

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back to your safe routes.'), findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('opens register screen from get started', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TutelaApp());
    await _finishSplash(tester);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Create your safe-space account.'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('Already have an account? Sign in.'), findsOneWidget);
  });
}

Future<void> _finishSplash(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 3800));
  await tester.pumpAndSettle();
}
