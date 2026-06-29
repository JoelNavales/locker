import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'services/app_prefs.dart';
import 'services/auth_repository.dart';
import 'services/user_repository.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';
import 'views/onboarding_screen.dart';
import 'views/select_track_screen.dart';
import 'views/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fully disable the device's system bars (back/home/recents). Sticky mode
  // re-hides them automatically if a swipe reveals them, so navigation stays
  // in-app via each screen's own buttons.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const LockerApp(),
    ),
  );
}

class LockerApp extends StatelessWidget {
  const LockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AuthGate(),
      // The logged-out flow still uses named routes pushed on top of the gate.
      routes: {
        '/signup': (_) => const SignupScreen(),
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}

/// Decides the top-level screen from auth + profile state:
/// signed out → onboarding flow; signed in without a track → strand/course
/// step; otherwise → home.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const _Loading(),
      error: (error, stack) => const _Loading(),
      data: (user) {
        if (user == null) {
          // Returning users who signed out land straight on login; only true
          // first-timers see the onboarding flow.
          final bool returning = ref.watch(appPrefsProvider).hasAccountBefore;
          return returning ? const LoginScreen() : const OnboardingScreen();
        }

        final profile = ref.watch(userProfileProvider);
        return profile.when(
          loading: () => const _Loading(),
          error: (error, stack) => const _Loading(),
          data: (u) {
            if (u == null || !u.hasTrack) return const SelectTrackScreen();
            return const HomeScreen();
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
