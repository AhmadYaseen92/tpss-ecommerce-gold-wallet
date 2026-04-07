import 'package:tpss_ecommerce_gold_wallet/features/transfer/domain/entities/transfer_totals_entity.dart';

class CalculateTransferTotalsUseCase {
  const CalculateTransferTotalsUseCase({this.feePercent = 0.01});

  final double feePercent;

  TransferTotalsEntity call({
    required double units,
    required double pricePerUnit,
  }) {
    final subtotal = units * pricePerUnit;
    final fee = subtotal * feePercent;
    return TransferTotalsEntity(
      subtotal: subtotal,
      fee: fee,
      totalDeducted: subtotal + fee,
    );
  }
}
