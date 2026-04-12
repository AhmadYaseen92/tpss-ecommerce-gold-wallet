part of 'wallet_cubit.dart';

class WalletState {}

final class WalletInitial extends WalletState {}

final class WalletLoading extends WalletState {}

final class WalletLoaded extends WalletState {
  final List<WalletEntity> wallets;
  final int? selectedCategoryId;

  WalletLoaded({required this.wallets, required this.selectedCategoryId});
}

final class WalletError extends WalletState {
  final String message;

  WalletError(this.message);
}
