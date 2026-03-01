part of 'sell_cubit.dart';

class SellState {
  static const double feePercent = 0.02;

}

final class SellInitial extends SellState {}

final class SellDataChanged extends SellState {
  final double units;
  final bool agreedToTerms;
  final int selectedAssetIndex;

  SellDataChanged({required this.units, required this.agreedToTerms, required this.selectedAssetIndex});

}

final class SellLoading extends SellState {}

final class SellSuccess extends SellState {}

final class SellError extends SellState {
  final String message;

  SellError(this.message);
}
