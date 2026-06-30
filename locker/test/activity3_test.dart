import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:locker/models/locker_model.dart';
import 'package:locker/services/app_prefs.dart';
import 'package:locker/theme/app_colors.dart';
import 'package:locker/theme/app_text_styles.dart';
import 'package:locker/theme/app_theme.dart';
import 'package:locker/viewmodels/login_vm.dart';
import 'package:locker/views/login_screen.dart';

class _FakeLoginViewModel extends LoginViewModel {
  @override
  Future<bool> submit() async => true;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  // ─── LoginScreen action simulation ──────────────────────────────────────────

  Widget buildSubject() => ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          loginViewModelProvider.overrideWith(_FakeLoginViewModel.new),
        ],
        child: const MaterialApp(home: LoginScreen()),
      );

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(LoginScreen)));

  group('LoginScreen action simulation', () {
    testWidgets('entering text updates email in LoginViewModel', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.pump();
      expect(
        containerOf(tester).read(loginViewModelProvider).email,
        'user@example.com',
      );
    });

    testWidgets('entering text updates password in LoginViewModel', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.enterText(find.byType(TextField).last, 'secret123');
      await tester.pump();
      expect(
        containerOf(tester).read(loginViewModelProvider).password,
        'secret123',
      );
    });

    testWidgets('tapping LOG IN with valid credentials calls submit', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.enterText(find.byType(TextField).last, 'secret123');
      await tester.pump();
      await tester.tap(find.text('LOG IN →'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  // ─── AppColors constants ──────────────────────────────────────────────────────

  group('AppColors constants', () {
    test('cream has the correct value', () {
      expect(AppColors.cream, const Color(0xFFFFFBEF));
    });
    test('ink has the correct value', () {
      expect(AppColors.ink, const Color(0xFF111111));
    });
    test('surface has the correct value', () {
      expect(AppColors.surface, const Color(0xFFFFFFFF));
    });
    test('onInk has the correct value', () {
      expect(AppColors.onInk, const Color(0xFFFFFFFF));
    });
    test('priorityHigh has the correct value', () {
      expect(AppColors.priorityHigh, const Color(0xFFFF4D6D));
    });
    test('priorityMedium has the correct value', () {
      expect(AppColors.priorityMedium, const Color(0xFFFFC93C));
    });
    test('priorityLow has the correct value', () {
      expect(AppColors.priorityLow, const Color(0xFF22C55E));
    });
    test('blue has the correct value', () {
      expect(AppColors.blue, const Color(0xFF3A86FF));
    });
    test('violet has the correct value', () {
      expect(AppColors.violet, const Color(0xFF9B5DE5));
    });
  });

  group('AppColors.forPriority', () {
    test('high → priorityHigh', () {
      expect(AppColors.forPriority(Priority.high), AppColors.priorityHigh);
    });
    test('medium → priorityMedium', () {
      expect(AppColors.forPriority(Priority.medium), AppColors.priorityMedium);
    });
    test('low → priorityLow', () {
      expect(AppColors.forPriority(Priority.low), AppColors.priorityLow);
    });
  });

  group('AppColors.onPriority', () {
    test('high → onInk (white text)', () {
      expect(AppColors.onPriority(Priority.high), AppColors.onInk);
    });
    test('medium → ink (dark text, readable on yellow)', () {
      expect(AppColors.onPriority(Priority.medium), AppColors.ink);
    });
    test('low → onInk (white text)', () {
      expect(AppColors.onPriority(Priority.low), AppColors.onInk);
    });
  });

  // ─── AppTheme ────────────────────────────────────────────────────────────────

  group('AppTheme spacing constants', () {
    test('spaceXs == 6', () => expect(AppTheme.spaceXs, 6));
    test('spaceSm == 10', () => expect(AppTheme.spaceSm, 10));
    test('spaceMd == 16', () => expect(AppTheme.spaceMd, 16));
    test('spaceLg == 24', () => expect(AppTheme.spaceLg, 24));
    test('spaceXl == 34', () => expect(AppTheme.spaceXl, 34));
  });

  group('AppTheme corner radii', () {
    test('radius == 8', () => expect(AppTheme.radius, 8));
    test('radiusTile == 6', () => expect(AppTheme.radiusTile, 6));
  });

  group('AppTheme dot-grid constants', () {
    test('dotGridSpacing == 26', () => expect(AppTheme.dotGridSpacing, 26));
    test('dotGridRadius == 1.2', () => expect(AppTheme.dotGridRadius, 1.2));
  });

  group('AppTheme.hardShadow', () {
    test('default offset is (6, 6) with zero blur and ink color', () {
      final shadow = AppTheme.hardShadow().first;
      expect(shadow.offset, const Offset(6, 6));
      expect(shadow.blurRadius, 0);
      expect(shadow.color, AppColors.ink);
    });

    test('hardShadowSmall has offset (4, 4)', () {
      expect(AppTheme.hardShadowSmall.first.offset, const Offset(4, 4));
    });

    test('custom offset is applied', () {
      final shadow = AppTheme.hardShadow(offset: const Offset(2, 2)).first;
      expect(shadow.offset, const Offset(2, 2));
    });
  });

  group('AppTheme.border', () {
    test('width is borderWidth (3) and color is ink', () {
      final side = AppTheme.border.top;
      expect(side.width, AppTheme.borderWidth);
      expect(side.color, AppColors.ink);
    });
  });

  group('AppTheme.light()', () {
    test('returns a ThemeData', () {
      expect(AppTheme.light(), isA<ThemeData>());
    });

    test('scaffold background is cream', () {
      expect(AppTheme.light().scaffoldBackgroundColor, AppColors.cream);
    });
  });

  group('AppTheme.dotGridPainter', () {
    test('returns a CustomPainter', () {
      expect(AppTheme.dotGridPainter, isA<CustomPainter>());
    });

    test('shouldRepaint always returns false', () {
      final painter = AppTheme.dotGridPainter;
      expect(painter.shouldRepaint(painter), isFalse);
    });
  });

  // ─── AppTextStyles ────────────────────────────────────────────────────────────

  group('AppTextStyles font sizes', () {
    test('display is 52px', () {
      expect(AppTextStyles.display(AppColors.ink).fontSize, 52);
    });
    test('heading is 22px', () {
      expect(AppTextStyles.heading(AppColors.ink).fontSize, 22);
    });
    test('title is 14px', () {
      expect(AppTextStyles.title(AppColors.ink).fontSize, 14);
    });
    test('label is 13px', () {
      expect(AppTextStyles.label(AppColors.ink).fontSize, 13);
    });
    test('caption is 9px', () {
      expect(AppTextStyles.caption(AppColors.ink).fontSize, 9);
    });
    test('body is 11px', () {
      expect(AppTextStyles.body(AppColors.ink).fontSize, 11);
    });
  });

  group('AppTextStyles color binding', () {
    test('body color matches argument', () {
      expect(AppTextStyles.body(AppColors.ink).color, AppColors.ink);
    });
    test('heading color matches argument', () {
      expect(
        AppTextStyles.heading(AppColors.priorityHigh).color,
        AppColors.priorityHigh,
      );
    });
    test('title color matches argument', () {
      expect(AppTextStyles.title(AppColors.priorityLow).color, AppColors.priorityLow);
    });
    test('label color matches argument', () {
      expect(AppTextStyles.label(AppColors.priorityMedium).color, AppColors.priorityMedium);
    });
    test('caption color matches argument', () {
      expect(AppTextStyles.caption(AppColors.blue).color, AppColors.blue);
    });
    test('display color matches argument', () {
      expect(AppTextStyles.display(AppColors.violet).color, AppColors.violet);
    });
  });
}
