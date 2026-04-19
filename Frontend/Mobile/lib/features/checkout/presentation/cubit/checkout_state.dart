part of 'checkout_cubit.dart';

class CheckoutState {}

final class CheckoutInitial extends CheckoutState {}

final class CheckoutDataChanged extends CheckoutState {
  final CheckoutPaymentType selectedPaymentType;
  final bool otpConfirmed;
  final List<PredefinedAccount> linkedBankAccounts;
  final List<PredefinedAccount> predefinedPaymentMethods;
  final int selectedBankIndex;
  final int selectedPaymentIndex;

  CheckoutDataChanged({
    required this.selectedPaymentType,
    required this.otpConfirmed,
    required this.linkedBankAccounts,
    required this.predefinedPaymentMethods,
    required this.selectedBankIndex,
    required this.selectedPaymentIndex,
  });
}

final class CheckoutLoading extends CheckoutState {}

final class CheckoutSuccess extends CheckoutState {}

final class CheckoutError extends CheckoutState {
  final String message;

  CheckoutError(this.message);
}
