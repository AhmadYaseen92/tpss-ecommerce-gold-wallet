import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/models/wallet_model.dart';

enum WalletActionType { sell, transfer, gift, convertToCash, convertToCrypto }


enum ConvertTargetType { cash, crypto }

class WalletActionSummary {
  final WalletTransaction asset;
  final WalletActionType actionType;
  final String title;
  final String primaryValue;
  final String feeValue;
  final String totalValue;
  final String destinationLabel;
  final String destinationValue;
  final String? note;
  final String referenceNumber;
  final DateTime createdAt;
  final bool isPending;

  const WalletActionSummary({
    required this.asset,
    required this.actionType,
    required this.title,
    required this.primaryValue,
    required this.feeValue,
    required this.totalValue,
    required this.destinationLabel,
    required this.destinationValue,
    this.note,
    required this.referenceNumber,
    required this.createdAt,
    this.isPending = false,
  });
}
