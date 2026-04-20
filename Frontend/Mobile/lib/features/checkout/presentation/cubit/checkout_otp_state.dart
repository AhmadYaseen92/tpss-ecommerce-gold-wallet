part of 'checkout_otp_cubit.dart';

sealed class CheckoutOtpState {}

class CheckoutOtpInitial extends CheckoutOtpState {}

class CheckoutOtpLoading extends CheckoutOtpState {}

class CheckoutOtpReady extends CheckoutOtpState {
  CheckoutOtpReady(this.otpRequestId);

  final String otpRequestId;
}

class CheckoutOtpFailure extends CheckoutOtpState {
  CheckoutOtpFailure(this.message);

  final String message;
}
