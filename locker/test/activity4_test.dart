import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locker/models/user_model.dart';
import 'package:locker/viewmodels/home_vm.dart';
import 'package:locker/viewmodels/login_vm.dart';
import 'package:locker/viewmodels/onboarding_vm.dart';
import 'package:locker/viewmodels/signup_vm.dart';
import 'package:locker/viewmodels/track_vm.dart';

void main() {
  // ─── LoginState ──────────────────────────────────────────────────────────────
  group('LoginState.isEmailValid', () {
    test('valid email returns true', () {
      expect(const LoginState(email: 'user@example.com').isEmailValid, isTrue);
    });

    test('invalid email returns false', () {
      expect(const LoginState(email: 'bad').isEmailValid, isFalse);
    });

    test('empty email returns false', () {
      expect(const LoginState(email: '').isEmailValid, isFalse);
    });
  });

  group('LoginState.isPasswordValid', () {
    test('non-empty password is valid', () {
      expect(const LoginState(password: 'secret').isPasswordValid, isTrue);
    });

    test('empty password is invalid', () {
      expect(const LoginState(password: '').isPasswordValid, isFalse);
    });
  });

  group('LoginState.canSubmit', () {
    test('true when email and password are valid', () {
      expect(
        const LoginState(email: 'a@b.com', password: '123456').canSubmit,
        isTrue,
      );
    });

    test('false while isSubmitting', () {
      expect(
        const LoginState(
          email: 'a@b.com',
          password: '123456',
          isSubmitting: true,
        ).canSubmit,
        isFalse,
      );
    });

    test('false when email is invalid', () {
      expect(
        const LoginState(email: 'bad', password: '123456').canSubmit,
        isFalse,
      );
    });

    test('false when password is empty', () {
      expect(
        const LoginState(email: 'a@b.com', password: '').canSubmit,
        isFalse,
      );
    });
  });

  group('LoginState.copyWith', () {
    const base = LoginState(email: 'a@b.com', password: '123', errorMessage: 'Oops');

    test('clears errorMessage when clearError is true', () {
      expect(base.copyWith(clearError: true).errorMessage, isNull);
    });

    test('preserves existing errorMessage when clearError is false', () {
      expect(base.copyWith(email: 'c@d.com').errorMessage, 'Oops');
    });

    test('sets new errorMessage', () {
      expect(base.copyWith(errorMessage: 'New').errorMessage, 'New');
    });

    test('changes obscurePassword', () {
      expect(
        const LoginState(obscurePassword: false)
            .copyWith(obscurePassword: true)
            .obscurePassword,
        isTrue,
      );
    });

    test('changes isSubmitting', () {
      expect(base.copyWith(isSubmitting: true).isSubmitting, isTrue);
    });
  });

  // ─── LoginViewModel ──────────────────────────────────────────────────────────
  group('LoginViewModel state mutations', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('setEmail updates email', () {
      container.read(loginViewModelProvider.notifier).setEmail('test@example.com');
      expect(container.read(loginViewModelProvider).email, 'test@example.com');
    });

    test('setPassword updates password', () {
      container.read(loginViewModelProvider.notifier).setPassword('mypass');
      expect(container.read(loginViewModelProvider).password, 'mypass');
    });

    test('toggleObscure flips obscurePassword from true to false', () {
      expect(container.read(loginViewModelProvider).obscurePassword, isTrue);
      container.read(loginViewModelProvider.notifier).toggleObscure();
      expect(container.read(loginViewModelProvider).obscurePassword, isFalse);
    });

    test('toggleObscure flips obscurePassword back to true', () {
      container.read(loginViewModelProvider.notifier).toggleObscure();
      container.read(loginViewModelProvider.notifier).toggleObscure();
      expect(container.read(loginViewModelProvider).obscurePassword, isTrue);
    });
  });

  // ─── SignupState ──────────────────────────────────────────────────────────────
  group('SignupState.isNameValid', () {
    test('name with 5+ characters is valid', () {
      expect(const SignupState(name: 'Alice').isNameValid, isTrue);
    });

    test('name with fewer than 5 characters is invalid', () {
      expect(const SignupState(name: 'Bob').isNameValid, isFalse);
    });

    test('empty name is invalid', () {
      expect(const SignupState(name: '').isNameValid, isFalse);
    });
  });

  group('SignupState.isPasswordValid', () {
    test('password with 6+ characters is valid', () {
      expect(const SignupState(password: '123456').isPasswordValid, isTrue);
    });

    test('password with fewer than 6 characters is invalid', () {
      expect(const SignupState(password: '123').isPasswordValid, isFalse);
    });
  });

  group('SignupState.doPasswordsMatch', () {
    test('matching passwords return true', () {
      expect(
        const SignupState(
          password: 'pass123',
          confirmPassword: 'pass123',
        ).doPasswordsMatch,
        isTrue,
      );
    });

    test('mismatched passwords return false', () {
      expect(
        const SignupState(password: 'abc', confirmPassword: 'xyz').doPasswordsMatch,
        isFalse,
      );
    });
  });

  group('SignupState.canSubmit', () {
    test('true when all fields are valid', () {
      expect(
        const SignupState(
          name: 'Alice',
          email: 'alice@example.com',
          password: 'secret1',
          confirmPassword: 'secret1',
        ).canSubmit,
        isTrue,
      );
    });

    test('false when passwords do not match', () {
      expect(
        const SignupState(
          name: 'Alice',
          email: 'alice@example.com',
          password: 'secret1',
          confirmPassword: 'other',
        ).canSubmit,
        isFalse,
      );
    });

    test('false while isSubmitting', () {
      expect(
        const SignupState(
          name: 'Alice',
          email: 'alice@example.com',
          password: 'secret1',
          confirmPassword: 'secret1',
          isSubmitting: true,
        ).canSubmit,
        isFalse,
      );
    });
  });

  // ─── SignupViewModel ──────────────────────────────────────────────────────────
  group('SignupViewModel state mutations', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('setName updates name', () {
      container.read(signupViewModelProvider.notifier).setName('Alice');
      expect(container.read(signupViewModelProvider).name, 'Alice');
    });

    test('setEmail updates email', () {
      container.read(signupViewModelProvider.notifier).setEmail('a@b.com');
      expect(container.read(signupViewModelProvider).email, 'a@b.com');
    });

    test('setPassword updates password', () {
      container.read(signupViewModelProvider.notifier).setPassword('mypass');
      expect(container.read(signupViewModelProvider).password, 'mypass');
    });

    test('setConfirmPassword updates confirmPassword', () {
      container.read(signupViewModelProvider.notifier).setConfirmPassword('mypass');
      expect(container.read(signupViewModelProvider).confirmPassword, 'mypass');
    });

    test('toggleObscure flips obscurePassword from true to false', () {
      expect(container.read(signupViewModelProvider).obscurePassword, isTrue);
      container.read(signupViewModelProvider.notifier).toggleObscure();
      expect(container.read(signupViewModelProvider).obscurePassword, isFalse);
    });

    test('toggleObscure flips obscurePassword back to true', () {
      container.read(signupViewModelProvider.notifier).toggleObscure();
      container.read(signupViewModelProvider.notifier).toggleObscure();
      expect(container.read(signupViewModelProvider).obscurePassword, isTrue);
    });
  });

  // ─── HomeState + HomeViewModel ────────────────────────────────────────────────
  group('HomeState.copyWith', () {
    test('changes selectedNavIndex', () {
      expect(
        const HomeState(selectedNavIndex: 0).copyWith(selectedNavIndex: 2).selectedNavIndex,
        2,
      );
    });

    test('preserves unchanged fields when called with no args', () {
      expect(const HomeState(selectedNavIndex: 1).copyWith().selectedNavIndex, 1);
    });
  });

  group('HomeViewModel', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial selectedNavIndex is 0', () {
      expect(container.read(homeViewModelProvider).selectedNavIndex, 0);
    });

    test('selectNav updates selectedNavIndex', () {
      container.read(homeViewModelProvider.notifier).selectNav(2);
      expect(container.read(homeViewModelProvider).selectedNavIndex, 2);
    });

    test('selectNav with same index is a no-op (identical state)', () {
      final before = container.read(homeViewModelProvider);
      container.read(homeViewModelProvider.notifier).selectNav(0);
      expect(identical(container.read(homeViewModelProvider), before), isTrue);
    });
  });

  // ─── OnboardingViewModel ─────────────────────────────────────────────────────
  group('OnboardingPage content', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('first page lockerNumber is 07', () {
      expect(
        container.read(onboardingViewModelProvider).pages[0].lockerNumber,
        '07',
      );
    });

    test('first page tagline', () {
      expect(
        container.read(onboardingViewModelProvider).pages[0].tagline,
        'YOUR STUDY LIFE. LOCKED IN.',
      );
    });

    test('second page lockerNumber is 12', () {
      expect(
        container.read(onboardingViewModelProvider).pages[1].lockerNumber,
        '12',
      );
    });

    test('third page lockerNumber is 24', () {
      expect(
        container.read(onboardingViewModelProvider).pages[2].lockerNumber,
        '24',
      );
    });
  });

  group('OnboardingState.copyWith', () {
    test('changes currentPage', () {
      const s = OnboardingState(pages: [], currentPage: 0);
      expect(s.copyWith(currentPage: 2).currentPage, 2);
    });

    test('preserves pages list', () {
      const pages = [OnboardingPage(lockerNumber: '01', tagline: 'Test')];
      const s = OnboardingState(pages: pages, currentPage: 0);
      expect(s.copyWith(currentPage: 1).pages, pages);
    });
  });

  group('OnboardingViewModel', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 3 pages', () {
      expect(container.read(onboardingViewModelProvider).pages.length, 3);
    });

    test('initial currentPage is 0', () {
      expect(container.read(onboardingViewModelProvider).currentPage, 0);
    });

    test('isLastPage is false on page 0', () {
      expect(container.read(onboardingViewModelProvider).isLastPage, isFalse);
    });

    test('isLastPage is true on the last page', () {
      container.read(onboardingViewModelProvider.notifier).setPage(2);
      expect(container.read(onboardingViewModelProvider).isLastPage, isTrue);
    });

    test('setPage updates currentPage', () {
      container.read(onboardingViewModelProvider.notifier).setPage(1);
      expect(container.read(onboardingViewModelProvider).currentPage, 1);
    });

    test('setPage with same index is a no-op (identical state)', () {
      final before = container.read(onboardingViewModelProvider);
      container.read(onboardingViewModelProvider.notifier).setPage(0);
      expect(identical(container.read(onboardingViewModelProvider), before), isTrue);
    });
  });

  // ─── TrackState ───────────────────────────────────────────────────────────────
  group('TrackState.track', () {
    test('initial level is shs', () {
      expect(const TrackState().level, EducationLevel.shs);
    });

    test('null when shs and no strand selected', () {
      expect(const TrackState().track, isNull);
    });

    test('returns selected strand for shs', () {
      expect(const TrackState(strand: 'STEM').track, 'STEM');
    });

    test('returns trimmed course for college', () {
      expect(
        const TrackState(
          level: EducationLevel.college,
          course: '  BS Computer Science  ',
        ).track,
        'BS Computer Science',
      );
    });

    test('returns empty string for college with empty course', () {
      expect(const TrackState(level: EducationLevel.college).track, '');
    });
  });

  group('TrackState.canSubmit', () {
    test('false when no track (shs, no strand)', () {
      expect(const TrackState().canSubmit, isFalse);
    });

    test('true when strand is selected', () {
      expect(const TrackState(strand: 'ABM').canSubmit, isTrue);
    });

    test('false when college with empty course', () {
      expect(
        const TrackState(level: EducationLevel.college).canSubmit,
        isFalse,
      );
    });

    test('false when college with whitespace-only course', () {
      expect(
        const TrackState(level: EducationLevel.college, course: '   ').canSubmit,
        isFalse,
      );
    });

    test('true when college with a non-empty course', () {
      expect(
        const TrackState(level: EducationLevel.college, course: 'BS Nursing').canSubmit,
        isTrue,
      );
    });

    test('false while isSubmitting', () {
      expect(
        const TrackState(strand: 'STEM', isSubmitting: true).canSubmit,
        isFalse,
      );
    });
  });

  group('TrackState.copyWith', () {
    const base = TrackState(
      level: EducationLevel.shs,
      strand: 'STEM',
      course: 'CS',
      errorMessage: 'Err',
    );

    test('changes level', () {
      expect(
        base.copyWith(level: EducationLevel.college).level,
        EducationLevel.college,
      );
    });

    test('changes strand', () {
      expect(base.copyWith(strand: 'ABM').strand, 'ABM');
    });

    test('changes course', () {
      expect(base.copyWith(course: 'BS Nursing').course, 'BS Nursing');
    });

    test('changes isSubmitting', () {
      expect(base.copyWith(isSubmitting: true).isSubmitting, isTrue);
    });

    test('clears errorMessage when clearError is true', () {
      expect(base.copyWith(clearError: true).errorMessage, isNull);
    });

    test('preserves errorMessage when clearError is false', () {
      expect(base.copyWith(level: EducationLevel.college).errorMessage, 'Err');
    });

    test('sets new errorMessage', () {
      expect(base.copyWith(errorMessage: 'New').errorMessage, 'New');
    });
  });

  // ─── TrackViewModel ──────────────────────────────────────────────────────────
  group('TrackViewModel.shsStrands', () {
    test('contains 7 strands', () {
      expect(TrackViewModel.shsStrands.length, 7);
    });

    test('includes STEM and ABM', () {
      expect(TrackViewModel.shsStrands, containsAll(['STEM', 'ABM']));
    });

    test('includes all standard strands', () {
      expect(
        TrackViewModel.shsStrands,
        containsAll([
          'STEM',
          'ABM',
          'HUMSS',
          'GAS',
          'TVL',
          'Arts & Design',
          'Sports',
        ]),
      );
    });
  });

  group('TrackViewModel state transitions', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial level is shs', () {
      expect(container.read(trackViewModelProvider).level, EducationLevel.shs);
    });

    test('setLevel switches to college', () {
      container.read(trackViewModelProvider.notifier).setLevel(EducationLevel.college);
      expect(container.read(trackViewModelProvider).level, EducationLevel.college);
    });

    test('selectStrand updates strand', () {
      container.read(trackViewModelProvider.notifier).selectStrand('HUMSS');
      expect(container.read(trackViewModelProvider).strand, 'HUMSS');
    });

    test('selectStrand makes canSubmit true', () {
      container.read(trackViewModelProvider.notifier).selectStrand('STEM');
      expect(container.read(trackViewModelProvider).canSubmit, isTrue);
    });

    test('setCourse updates course', () {
      container.read(trackViewModelProvider.notifier).setCourse('BS Nursing');
      expect(container.read(trackViewModelProvider).course, 'BS Nursing');
    });

    test('switching to college makes canSubmit false until course is set', () {
      container.read(trackViewModelProvider.notifier).selectStrand('STEM');
      container.read(trackViewModelProvider.notifier).setLevel(EducationLevel.college);
      expect(container.read(trackViewModelProvider).canSubmit, isFalse);
    });

    test('setCourse after switching to college makes canSubmit true', () {
      container.read(trackViewModelProvider.notifier).setLevel(EducationLevel.college);
      container.read(trackViewModelProvider.notifier).setCourse('BS CS');
      expect(container.read(trackViewModelProvider).canSubmit, isTrue);
    });
  });
}
