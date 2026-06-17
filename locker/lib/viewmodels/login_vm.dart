import 'package:flutter_riverpod/flutter_riverpod.dart';


class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
  });

  final String email;
  final String password;
  final bool obscurePassword;

  bool get isEmailValid => RegExp(
        r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
      ).hasMatch(email.trim());

  bool get isPasswordValid => password.isNotEmpty;

  bool get canSubmit => isEmailValid && isPasswordValid;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void setEmail(String value) => state = state.copyWith(email: value);

  void setPassword(String value) => state = state.copyWith(password: value);

  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void submit() {
    if (!state.canSubmit) return;
    // TODO: wire Firebase Auth — sign in with email & password.
  }
}

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);
