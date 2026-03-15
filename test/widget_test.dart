// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:credito_app/src/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return ProviderScope(child: MaterialApp(home: child));
  }

  testWidgets('login page shows fields and create account action', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const LoginPage()));

    expect(find.text('Login'), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Create account'), findsOneWidget);
  });

  testWidgets('tapping create account opens the registration page', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const LoginPage()));

    await tester.tap(find.widgetWithText(TextButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Sign up with your email'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
  });
}
