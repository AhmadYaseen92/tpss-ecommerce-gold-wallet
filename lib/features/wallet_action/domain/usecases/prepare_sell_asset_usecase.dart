import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/entities/sell_asset_entities.dart';

class PrepareSellAssetUseCase {
  const PrepareSellAssetUseCase();

  SellAssetResultEntity call(SellAssetRequestEntity request) {
    if (!request.marketOpen) {
      throw Exception('Market is closed. Please try again during trading hours.');
    }

    if (request.quantity < 1 || request.quantity > request.maxQuantity) {
      throw Exception('Requested quantity is invalid.');
    }

    final grossAmount = request.lockedPrice * request.quantity;
    if (request.availableLiquidity < grossAmount) {
      throw Exception('Insufficient market liquidity for this order.');
    }

    const feeRate = 0.008;
    final feeAmount = grossAmount * feeRate;
    final receivedAmount = grossAmount - feeAmount;

    return SellAssetResultEntity(
      quantity: request.quantity,
      grossAmount: grossAmount,
      feeAmount: feeAmount,
      receivedAmount: receivedAmount,
      lockedUnitPrice: request.lockedPrice,
    );
  }
}
