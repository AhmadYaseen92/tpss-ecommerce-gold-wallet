part of 'sell_asset_action_cubit.dart';

sealed class SellAssetActionState {}

final class SellAssetActionInitial extends SellAssetActionState {}

final class SellAssetActionUpdated extends SellAssetActionState {
  SellAssetActionUpdated({required this.result, this.errorMessage});

  final SellAssetResultEntity? result;
  final String? errorMessage;
}
