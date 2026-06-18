import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight wrapper over [SharedPreferences] for small, device-local flags.
///
/// Right now it only remembers whether anyone has ever signed in on this
/// device, so the login screen can greet returning users ("Welcome back")
/// differently from brand-new ones ("Welcome to locker").
class AppPrefs {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const String _hasAccountKey = 'has_account_before';

  bool get hasAccountBefore => _prefs.getBool(_hasAccountKey) ?? false;

  Future<void> markHasAccount() => _prefs.setBool(_hasAccountKey, true);
}

/// Overridden in `main()` with the instance loaded before the app starts.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main().',
  );
});

final appPrefsProvider = Provider<AppPrefs>((ref) {
  return AppPrefs(ref.watch(sharedPreferencesProvider));
});
