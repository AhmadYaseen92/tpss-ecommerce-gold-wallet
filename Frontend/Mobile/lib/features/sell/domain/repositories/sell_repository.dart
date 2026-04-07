abstract class ISellRepository {
  Future<void> warmup();

  double currentPriceForAsset({
    required int assetIndex,
    required int refreshCount,
  });

  Future<void> submitSellOrder();
}
