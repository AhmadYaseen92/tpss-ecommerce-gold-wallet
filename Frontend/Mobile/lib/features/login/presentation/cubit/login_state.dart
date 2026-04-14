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
  LoginRememberMeChanged({required this.rememberMe});
}

final class LoginPasswordVisibilityChanged extends LoginState {
  final bool obscurePassword;
  LoginPasswordVisibilityChanged({required this.obscurePassword});
}

final class LoginServerCheckResult extends LoginState {
  final bool success;
  final String message;
  LoginServerCheckResult({required this.success, required this.message});
}

final class LoginServerConfigUpdated extends LoginState {
  final String baseUrl;
  final int timeoutSeconds;

  LoginServerConfigUpdated({
    required this.baseUrl,
    required this.timeoutSeconds,
  });
}

class LoginBiometricDetected extends LoginState {
  final BiometricTypeUI type;
  LoginBiometricDetected(this.type);
}
