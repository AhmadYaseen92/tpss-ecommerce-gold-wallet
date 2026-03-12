part of 'transfer_cubit.dart';

enum RecipientMode { email, phone }

class TransferState {
  static const double feePercent = 0.01;
}

final class TransferInitial extends TransferState {}

final class TransferLoading extends TransferState {}

final class TransferDataChanged extends TransferState {
  final double units;
  final int selectedAssetIndex;
  final RecipientMode recipientMode;
  final bool agreedToTerms;

  TransferDataChanged({
    required this.units,
    required this.selectedAssetIndex,
    required this.recipientMode,
    required this.agreedToTerms,
  });
}

final class TransferSuccess extends TransferState {}

final class TransferError extends TransferState {
  final String message;
  TransferError(this.message);
}
