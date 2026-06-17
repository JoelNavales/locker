import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../viewmodels/signup_vm.dart';
import '../widgets/neu_button.dart';
import '../widgets/neu_text_field.dart';
class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SignupState state = ref.watch(signupViewModelProvider);
    final SignupViewModel vm = ref.read(signupViewModelProvider.notifier);

    return Scaffold(
      body: Stack(
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
                  Text('CREATE\nACCOUNT',
                      style: AppTextStyles.display(AppColors.ink)
                          .copyWith(fontSize: 40)),
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
                  const SizedBox(height: AppTheme.spaceLg),
                  NeuButton(
                    label: 'CREATE ACCOUNT',
                    color: AppColors.priorityHigh,
                    foreground: AppColors.onInk,
                    onTap: () {
                      vm.submit();
                      // UI-only phase: enter the app without real auth yet.
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/home', (_) => false);
                    },
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                      child: Text(
                        'ALREADY HAVE A KEY? LOG IN',
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
