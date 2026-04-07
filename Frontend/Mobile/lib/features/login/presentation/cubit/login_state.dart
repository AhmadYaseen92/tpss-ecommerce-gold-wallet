part of 'login_cubit.dart';

class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {}

final class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

final class LoginRememberMeChanged extends LoginState {

  final bool rememberMe;
  LoginRememberMeChanged({
    required this.rememberMe,
  });
}

final class LoginPasswordVisibilityChanged extends LoginState {
  final bool obscurePassword;
  LoginPasswordVisibilityChanged({required this.obscurePassword});
}

