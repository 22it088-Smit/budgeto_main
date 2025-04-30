// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:budgeto/app.dart';
import 'package:budgeto/services/auth_service.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/services/theme_service.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeService()),
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => BudgetService()),
        ],
        child: const BudgetoApp(),
      ),
    );

    // Verify that the app title is present
    expect(find.text('Budgeto'), findsOneWidget);

    // Verify that the login screen is shown initially
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue to Budgeto'), findsOneWidget);
  });

  testWidgets('Login form validation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeService()),
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => BudgetService()),
        ],
        child: const BudgetoApp(),
      ),
    );

    // Try to login without entering credentials
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify that validation messages are shown
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify that email validation message is shown
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });
}
