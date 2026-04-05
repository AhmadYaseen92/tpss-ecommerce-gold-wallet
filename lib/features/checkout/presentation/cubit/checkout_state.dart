part of 'checkout_cubit.dart';

class CheckoutState {}

final class CheckoutInitial extends CheckoutState {}

final class CheckoutDataChanged extends CheckoutState {
  final CheckoutPaymentType selectedPaymentType;
  final bool otpConfirmed;

  CheckoutDataChanged({
    required this.selectedPaymentType,
    required this.otpConfirmed,
  });
}

final class CheckoutLoading extends CheckoutState {}

final class CheckoutSuccess extends CheckoutState {}

final class CheckoutError extends CheckoutState {
  final String message;

  CheckoutError(this.message);
}
