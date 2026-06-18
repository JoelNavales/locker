import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../services/app_prefs.dart';
import '../viewmodels/login_vm.dart';
import '../widgets/error_banner.dart';
import '../widgets/neu_button.dart';
import '../widgets/neu_text_field.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> _handleLogin(BuildContext context, WidgetRef ref) async {
    final bool ok = await ref.read(loginViewModelProvider.notifier).submit();
    // On success, clear the auth stack so the AuthGate (root) takes over.
    if (ok && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LoginState state = ref.watch(loginViewModelProvider);
    final LoginViewModel vm = ref.read(loginViewModelProvider.notifier);
    // Returning users (who signed up/in before, then signed out) get a warmer
    // greeting; first-time visitors get the welcome.
    final bool isReturning = ref.watch(appPrefsProvider).hasAccountBefore;
    final String greeting =
        isReturning ? 'WELCOME BACK' : 'WELCOME TO LOCKER';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: AppTheme.dotGridPainter),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting,
                      style: AppTextStyles.display(AppColors.ink)
                          .copyWith(fontSize: 40)),
                  const SizedBox(height: AppTheme.spaceLg),
                  NeuTextField(
                    label: 'Email',
                    hint: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: vm.setEmail,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  NeuTextField(
                    label: 'Password',
                    obscure: state.obscurePassword,
                    onToggleObscure: vm.toggleObscure,
                    onChanged: vm.setPassword,
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppTheme.spaceMd),
                    ErrorBanner(message: state.errorMessage!),
                  ],
                  const SizedBox(height: AppTheme.spaceLg),
                  NeuButton(
                    label: state.isSubmitting ? 'LOGGING IN…' : 'LOG IN →',
                    color: AppColors.priorityMedium,
                    enabled: state.canSubmit,
                    onTap: () {
                      _handleLogin(context, ref);
                    },
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        final NavigatorState nav = Navigator.of(context);
                        // When login is the base route (returning user after
                        // sign-out) there's nothing to fall back to, so push
                        // signup on top rather than replacing the base — which
                        // would unmount the AuthGate underneath.
                        if (nav.canPop()) {
                          nav.pushReplacementNamed('/signup');
                        } else {
                          nav.pushNamed('/signup');
                        }
                      },
                      child: Text(
                        "DON'T HAVE A KEY? SIGN UP",
                        style: AppTextStyles.label(AppColors.ink).copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
