part of 'checkout_otp_cubit.dart';

sealed class CheckoutOtpState {}

class CheckoutOtpInitial extends CheckoutOtpState {}

class CheckoutOtpLoading extends CheckoutOtpState {}

class CheckoutOtpReady extends CheckoutOtpState {
  CheckoutOtpReady({
    required this.otpRequestId,
    required this.cooldownSeconds,
  });

  final String otpRequestId;
  final int cooldownSeconds;
}

class CheckoutOtpFailure extends CheckoutOtpState {
  CheckoutOtpFailure(this.message);

  final String message;
}
