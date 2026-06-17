import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_repository.dart';

class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool obscurePassword;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isEmailValid => RegExp(
        r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
      ).hasMatch(email.trim());

  bool get isPasswordValid => password.isNotEmpty;

  bool get canSubmit => isEmailValid && isPasswordValid && !isSubmitting;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void setEmail(String value) =>
      state = state.copyWith(email: value, clearError: true);

  void setPassword(String value) =>
      state = state.copyWith(password: value, clearError: true);

  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  /// Signs in with email & password. Returns true on success.
  Future<bool> submit() async {
    if (!state.canSubmit) return false;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: state.email, password: state.password);
      state = state.copyWith(isSubmitting: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state =
          state.copyWith(isSubmitting: false, errorMessage: authErrorMessage(e));
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }
}

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);
