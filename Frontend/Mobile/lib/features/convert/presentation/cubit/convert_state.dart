part of 'convert_cubit.dart';

class ConvertState {
  static const double feePercent = 0.01;
}

final class ConvertInitial extends ConvertState {}

final class ConvertDataChanged extends ConvertState {
  final double amount;
  final bool agreedToTerms;
  final String fromCurrency;

  ConvertDataChanged({
    required this.amount,
    required this.agreedToTerms,
    required this.fromCurrency,
  });
}

final class ConvertLoading extends ConvertState {}

final class ConvertSuccess extends ConvertState {}

final class ConvertError extends ConvertState {
  final String message;

  ConvertError(this.message);
}
