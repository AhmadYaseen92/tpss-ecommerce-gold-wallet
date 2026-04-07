import 'package:tpss_ecommerce_gold_wallet/features/sell/data/datasources/sell_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/repositories/sell_repository.dart';

class SellRepositoryImpl implements ISellRepository {
  SellRepositoryImpl(this._localDataSource);

  final SellLocalDataSource _localDataSource;

  @override
  Future<void> warmup() => _localDataSource.warmup();

  @override
  double currentPriceForAsset({
    required int assetIndex,
    required int refreshCount,
  }) {
    return _localDataSource.currentPriceForAsset(
      assetIndex: assetIndex,
      refreshCount: refreshCount,
    );
  }

  @override
  Future<void> submitSellOrder() => _localDataSource.submitSellOrder();
}
