import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../viewmodels/signup_vm.dart';
import '../widgets/error_banner.dart';
import '../widgets/neu_back_button.dart';
import '../widgets/neu_button.dart';
import '../widgets/neu_text_field.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  Future<void> _handleSignup(BuildContext context, WidgetRef ref) async {
    final bool ok = await ref.read(signupViewModelProvider.notifier).submit();
    // On success, clear the auth stack so the AuthGate (root) takes over and
    // routes the new user to the "where do you belong" step.
    if (ok && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SignupState state = ref.watch(signupViewModelProvider);
    final SignupViewModel vm = ref.read(signupViewModelProvider.notifier);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: CustomPaint(painter: AppTheme.dotGridPainter)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    NeuBackButton(onTap: () => Navigator.of(context).pop()),
                    const SizedBox(height: AppTheme.spaceLg),
                  ],
                  Text(
                    'CREATE\nACCOUNT',
                    style: AppTextStyles.display(
                      AppColors.ink,
                    ).copyWith(fontSize: 40),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                  NeuTextField(
                    label: 'Name',
                    hint: 'Jane Doe',
                    onChanged: vm.setName,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  NeuTextField(
                    label: 'Email',
                    hint: 'you@school.edu',
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
                  const SizedBox(height: AppTheme.spaceMd),
                  NeuTextField(
                    label: 'Confirm Password',
                    obscure: state.obscurePassword,
                    onToggleObscure: vm.toggleObscure,
                    onChanged: vm.setConfirmPassword,
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppTheme.spaceMd),
                    ErrorBanner(message: state.errorMessage!),
                  ],
                  const SizedBox(height: AppTheme.spaceLg),
                  NeuButton(
                    label: state.isSubmitting ? 'CREATING…' : 'CREATE ACCOUNT',
                    color: AppColors.priorityHigh,
                    foreground: AppColors.onInk,
                    enabled: state.canSubmit,
                    onTap: () {
                      _handleSignup(context, ref);
                    },
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                      child: Text(
                        'ALREADY HAVE A KEY? LOG IN',
                        style: AppTextStyles.label(
                          AppColors.ink,
                        ).copyWith(decoration: TextDecoration.underline),
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
