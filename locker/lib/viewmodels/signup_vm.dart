import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_repository.dart';

class SignupState {
  const SignupState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool obscurePassword;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isNameValid => name.trim().length >= 5;

  bool get isEmailValid =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(email.trim());

  bool get isPasswordValid => password.length >= 6;

  bool get doPasswordsMatch =>
      password.isNotEmpty && password == confirmPassword;

  bool get canSubmit =>
      isNameValid &&
      isEmailValid &&
      isPasswordValid &&
      doPasswordsMatch &&
      !isSubmitting;

  SignupState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SignupState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SignupViewModel extends Notifier<SignupState> {
  @override
  SignupState build() => const SignupState();

  void setName(String value) =>
      state = state.copyWith(name: value, clearError: true);

  void setEmail(String value) =>
      state = state.copyWith(email: value, clearError: true);

  void setPassword(String value) =>
      state = state.copyWith(password: value, clearError: true);

  void setConfirmPassword(String value) =>
      state = state.copyWith(confirmPassword: value, clearError: true);

  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  /// Creates the account with email & password. Returns true on success.
  Future<bool> submit() async {
    if (!state.canSubmit) return false;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            name: state.name,
            email: state.email,
            password: state.password,
          );
      state = state.copyWith(isSubmitting: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: authErrorMessage(e),
      );
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

final signupViewModelProvider = NotifierProvider<SignupViewModel, SignupState>(
  SignupViewModel.new,
);
