import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/entities/sell_totals_entity.dart';

class CalculateSellTotalsUseCase {
  const CalculateSellTotalsUseCase({this.feePercent = 0.02});

  final double feePercent;

  SellTotalsEntity call({
    required double units,
    required double pricePerUnit,
  }) {
    final subtotal = units * pricePerUnit;
    final fee = subtotal * feePercent;
    return SellTotalsEntity(
      subtotal: subtotal,
      fee: fee,
      net: subtotal - fee,
    );
  }
}
