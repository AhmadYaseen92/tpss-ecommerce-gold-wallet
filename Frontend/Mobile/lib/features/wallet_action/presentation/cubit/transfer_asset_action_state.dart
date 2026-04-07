part of 'transfer_asset_action_cubit.dart';

sealed class TransferAssetActionState {}

final class TransferAssetActionInitial extends TransferAssetActionState {}

final class TransferAssetActionUpdated extends TransferAssetActionState {}
