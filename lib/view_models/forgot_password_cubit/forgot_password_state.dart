part of 'forgot_password_cubit.dart';

class ForgotPasswordState {}

final class ForgotPasswordInitial extends ForgotPasswordState {}

final class ForgotPasswordLoading extends ForgotPasswordState {}

final class ForgotPasswordSuccess extends ForgotPasswordState {}

final class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  ForgotPasswordError(this.message);
}

final class ForgotPasswordStepChanged extends ForgotPasswordState {
  final int step;
  ForgotPasswordStepChanged({required this.step});
}

final class ForgotPasswordDeliveryMethodChanged extends ForgotPasswordState {
  final String method;
  ForgotPasswordDeliveryMethodChanged({required this.method});
}

final class ForgotPasswordOtpChanged extends ForgotPasswordState {
  final String otp;
  ForgotPasswordOtpChanged({required this.otp});
}

final class ForgotPasswordTimerTick extends ForgotPasswordState {
  final int secondsRemaining;
  ForgotPasswordTimerTick({required this.secondsRemaining});
}

final class ForgotPasswordPasswordVisibilityChanged extends ForgotPasswordState {
  final bool obscureNew;
  final bool obscureConfirm;
  ForgotPasswordPasswordVisibilityChanged({
    required this.obscureNew,
    required this.obscureConfirm,
  });
}
