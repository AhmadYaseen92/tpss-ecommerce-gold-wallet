import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/models/asset_model.dart';

class SellLocalDataSource {
  Future<void> warmup() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  double currentPriceForAsset({
    required int assetIndex,
    required int refreshCount,
  }) {
    final basePrice = Asset.assets[assetIndex].pricePerUnit;
    final factor = ((refreshCount + assetIndex) % 5) - 2;
    final changePercent = factor * 0.006;
    return (basePrice * (1 + changePercent)).clamp(0.01, double.infinity);
  }

  Future<void> submitSellOrder() async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
  }
}
