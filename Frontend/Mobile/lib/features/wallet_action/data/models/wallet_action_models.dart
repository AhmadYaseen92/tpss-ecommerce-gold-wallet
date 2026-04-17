import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';

enum WalletActionType { sell, transfer, gift, convertToCash, convertToCrypto }

enum ConvertTargetType { cash, crypto }

enum SellExecutionMode { locked30Seconds, livePrice }

class WalletActionSummary {
  final WalletTransactionEntity asset;
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

class WalletActionExecutionRequest {
  final int walletAssetId;
  final WalletActionType actionType;
  final int quantity;
  final double unitPrice;
  final double weight;
  final double amount;
  final String? notes;

  const WalletActionExecutionRequest({
    required this.walletAssetId,
    required this.actionType,
    required this.quantity,
    required this.unitPrice,
    required this.weight,
    required this.amount,
    this.notes,
  });
}

class WalletActionExecutionResult {
  final String referenceId;
  final String status;
  final double cashBalance;
  final double totalPortfolioValue;
  final DateTime? lockedPriceUntilUtc;

  const WalletActionExecutionResult({
    required this.referenceId,
    required this.status,
    required this.cashBalance,
    required this.totalPortfolioValue,
    this.lockedPriceUntilUtc,
  });
}
