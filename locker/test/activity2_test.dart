import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:locker/services/app_prefs.dart';
import 'package:locker/services/auth_repository.dart';
import 'package:locker/views/login_screen.dart';
import 'package:locker/widgets/neu_button.dart';
import 'package:locker/widgets/neu_text_field.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  // ─── LoginScreen widget tests ────────────────────────────────────────────────

  Widget buildLoginScreen() => ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: LoginScreen()),
      );

  group('LoginScreen widget tests', () {
    testWidgets('shows EMAIL and PASSWORD text fields', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.byType(NeuTextField), findsWidgets);
      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
    });

    testWidgets('shows LOG IN button', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.byType(NeuButton), findsOneWidget);
      expect(find.text('LOG IN →'), findsOneWidget);
    });

    testWidgets('shows WELCOME TO LOCKER for new users', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('WELCOME TO LOCKER'), findsOneWidget);
    });

    testWidgets('shows WELCOME BACK for returning users', (tester) async {
      await AppPrefs(prefs).markHasAccount();
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('WELCOME BACK'), findsOneWidget);
    });

    testWidgets("shows sign-up link text", (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text("DON'T HAVE A KEY? SIGN UP"), findsOneWidget);
    });
  });

  // ─── AppPrefs ────────────────────────────────────────────────────────────────

  group('AppPrefs', () {
    test('hasAccountBefore returns false initially', () {
      expect(AppPrefs(prefs).hasAccountBefore, isFalse);
    });

    test('hasAccountBefore returns true after markHasAccount()', () async {
      final appPrefs = AppPrefs(prefs);
      await appPrefs.markHasAccount();
      expect(appPrefs.hasAccountBefore, isTrue);
    });

    test('markHasAccount is idempotent', () async {
      final appPrefs = AppPrefs(prefs);
      await appPrefs.markHasAccount();
      await appPrefs.markHasAccount();
      expect(appPrefs.hasAccountBefore, isTrue);
    });
  });

  // ─── authErrorMessage ─────────────────────────────────────────────────────────

  group('authErrorMessage', () {
    FirebaseAuthException err(String code, {String? message}) =>
        FirebaseAuthException(code: code, message: message);

    test('invalid-email', () {
      expect(
        authErrorMessage(err('invalid-email')),
        'That email address looks invalid.',
      );
    });

    test('user-disabled', () {
      expect(
        authErrorMessage(err('user-disabled')),
        'This account has been disabled.',
      );
    });

    test('user-not-found → credential error', () {
      expect(
        authErrorMessage(err('user-not-found')),
        'Email or password is incorrect.',
      );
    });

    test('wrong-password → credential error', () {
      expect(
        authErrorMessage(err('wrong-password')),
        'Email or password is incorrect.',
      );
    });

    test('invalid-credential → credential error', () {
      expect(
        authErrorMessage(err('invalid-credential')),
        'Email or password is incorrect.',
      );
    });

    test('email-already-in-use', () {
      expect(
        authErrorMessage(err('email-already-in-use')),
        'An account already exists for that email.',
      );
    });

    test('weak-password', () {
      expect(
        authErrorMessage(err('weak-password')),
        'Password is too weak — use at least 6 characters.',
      );
    });

    test('network-request-failed', () {
      expect(
        authErrorMessage(err('network-request-failed')),
        'Network error. Check your connection.',
      );
    });

    test('unknown code falls back to exception message', () {
      expect(
        authErrorMessage(err('other', message: 'Custom error')),
        'Custom error',
      );
    });

    test('unknown code with null message → generic fallback', () {
      expect(
        authErrorMessage(err('other')),
        'Something went wrong. Please try again.',
      );
    });
  });
}
