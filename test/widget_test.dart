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

    expect(find.text('Getting started'), findsNothing);
    expect(find.text('Move through the city with confidence.'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.textContaining('Create an Account.'), findsOneWidget);
  });

  testWidgets('opens sign in screen from log in', (WidgetTester tester) async {
    await tester.pumpWidget(const TutelaApp());
    await _finishSplash(tester);

    await tester.tap(find.text('Log in'));
    await _finishAuthRoute(tester);

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
    await _finishAuthRoute(tester);

    expect(find.text('Create your safe-space account.'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('Already have an account? Sign in.'), findsOneWidget);
  });

  testWidgets('opens home after sign in', (WidgetTester tester) async {
    await tester.pumpWidget(const TutelaApp());
    await _finishSplash(tester);

    await tester.tap(find.text('Log in'));
    await _finishAuthRoute(tester);
    final signInButton = find.text('Sign in').last;
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Your safety overview for today.'), findsOneWidget);
    expect(find.text('Open Map Dashboard'), findsOneWidget);
    expect(find.text('SOS'), findsOneWidget);
  });

  testWidgets('opens map dashboard from home', (WidgetTester tester) async {
    await tester.pumpWidget(const TutelaApp());
    await _finishSplash(tester);

    await tester.tap(find.text('Log in'));
    await _finishAuthRoute(tester);
    final signInButton = find.text('Sign in').last;
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Rafaela'), findsOneWidget);
    expect(find.text('Search destination'), findsOneWidget);
    expect(find.text('Safer route available'), findsOneWidget);
  });

  testWidgets('opens report incident screen from map dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TutelaApp());
    await _finishSplash(tester);

    await tester.tap(find.text('Log in'));
    await _finishAuthRoute(tester);
    final signInButton = find.text('Sign in').last;
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();

    expect(find.text('Incident reports'), findsOneWidget);
    expect(find.text('CRUD safety data layer'), findsOneWidget);
    expect(find.text('Create'), findsNothing);
    expect(find.text('Read'), findsNothing);
    expect(find.text('Update'), findsNothing);
    expect(find.text('Delete'), findsNothing);
    expect(find.text('File a report'), findsOneWidget);
    expect(find.text('Browse map pins'), findsOneWidget);
    expect(find.text('Add follow-up'), findsOneWidget);
    expect(find.text('Remove report'), findsOneWidget);
  });
}

Future<void> _finishSplash(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 3800));
  await tester.pump(const Duration(milliseconds: 700));
}

Future<void> _finishAuthRoute(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 1100));
}
