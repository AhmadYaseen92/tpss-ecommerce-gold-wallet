class SellAssetRequestEntity {
  const SellAssetRequestEntity({
    required this.quantity,
    required this.maxQuantity,
    required this.unitPrice,
    required this.marketOpen,
    required this.availableLiquidity,
    required this.lockedPrice,
  });

  final int quantity;
  final int maxQuantity;
  final double unitPrice;
  final bool marketOpen;
  final double availableLiquidity;
  final double lockedPrice;
}

class SellAssetResultEntity {
  const SellAssetResultEntity({
    required this.quantity,
    required this.grossAmount,
    required this.feeAmount,
    required this.receivedAmount,
    required this.lockedUnitPrice,
  });

  final int quantity;
  final double grossAmount;
  final double feeAmount;
  final double receivedAmount;
  final double lockedUnitPrice;
}
