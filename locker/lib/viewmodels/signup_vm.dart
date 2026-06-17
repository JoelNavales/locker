import 'package:flutter_riverpod/flutter_riverpod.dart';
class SignupState {
  const SignupState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
  });

  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool obscurePassword;

  bool get isNameValid => name.trim().isNotEmpty;

  bool get isEmailValid => RegExp(
        r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
      ).hasMatch(email.trim());

  bool get isPasswordValid => password.length >= 6;

  bool get doPasswordsMatch =>
      password.isNotEmpty && password == confirmPassword;

  bool get canSubmit =>
      isNameValid && isEmailValid && isPasswordValid && doPasswordsMatch;

  SignupState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
  }) {
    return SignupState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}


class SignupViewModel extends Notifier<SignupState> {
  @override
  SignupState build() => const SignupState();

  void setName(String value) => state = state.copyWith(name: value);

  void setEmail(String value) => state = state.copyWith(email: value);

  void setPassword(String value) => state = state.copyWith(password: value);

  void setConfirmPassword(String value) =>
      state = state.copyWith(confirmPassword: value);

  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  /// Attempt to create an account.
  void submit() {
    if (!state.canSubmit) return;
    // TODO: wire Firebase Auth — create the user with email & password.
  }
}

final signupViewModelProvider =
    NotifierProvider<SignupViewModel, SignupState>(SignupViewModel.new);
