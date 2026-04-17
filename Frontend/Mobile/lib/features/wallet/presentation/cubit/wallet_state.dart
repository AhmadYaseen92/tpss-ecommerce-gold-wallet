part of 'wallet_cubit.dart';

class WalletState {}

final class WalletInitial extends WalletState {}

final class WalletLoading extends WalletState {}

final class WalletLoaded extends WalletState {
  final List<WalletEntity> wallets;
  final int? selectedCategoryId;
  final double totalPortfolioValue;

  WalletLoaded({required this.wallets, required this.selectedCategoryId, required this.totalPortfolioValue});
}

final class WalletError extends WalletState {
  final String message;

  WalletError(this.message);
}
