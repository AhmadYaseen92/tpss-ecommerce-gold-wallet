import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/core/models/action_summary_model.dart';

enum WalletActionType { sell, transfer, gift, pickup, convertToCash, convertToCrypto }

enum ConvertTargetType { cash, crypto }

enum SellExecutionMode { locked30Seconds, livePrice }

class WalletActionSummary {
  final WalletTransactionEntity asset;
  final WalletActionType actionType;
  final String title;
  final String primaryValue;
  final ActionSummaryModel summary;
  final WalletActionPreviewResult? preview;
  final String destinationLabel;
  final String destinationValue;
  final int? recipientInvestorUserId;
  final String? note;
  final String referenceNumber;
  final DateTime createdAt;
  final bool isPending;

  const WalletActionSummary({
    required this.asset,
    required this.actionType,
    required this.title,
    required this.primaryValue,
    required this.summary,
    this.preview,
    required this.destinationLabel,
    required this.destinationValue,
    this.recipientInvestorUserId,
    this.note,
    required this.referenceNumber,
    required this.createdAt,
    this.isPending = false,
  });
}

class WalletActionPreviewFeeLine {
  const WalletActionPreviewFeeLine({
    required this.feeName,
    required this.appliedValue,
    required this.isDiscount,
  });

  final String feeName;
  final double appliedValue;
  final bool isDiscount;
}

class WalletActionPreviewResult {
  const WalletActionPreviewResult({
    required this.subTotalAmount,
    required this.totalFeesAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.currency,
    required this.feeBreakdowns,
  });

  final double subTotalAmount;
  final double totalFeesAmount;
  final double discountAmount;
  final double finalAmount;
  final String currency;
  final List<WalletActionPreviewFeeLine> feeBreakdowns;
}

class WalletActionExecutionRequest {
  final int walletAssetId;
  final WalletActionType actionType;
  final int quantity;
  final double unitPrice;
  final double weight;
  final double amount;
  final String? notes;
  final int? recipientInvestorUserId;
  final String? otpVerificationToken;
  final String? otpActionReferenceId;

  const WalletActionExecutionRequest({
    required this.walletAssetId,
    required this.actionType,
    required this.quantity,
    required this.unitPrice,
    required this.weight,
    required this.amount,
    this.notes,
    this.recipientInvestorUserId,
    this.otpVerificationToken,
    this.otpActionReferenceId,
  });
}

class WalletActionExecutionResult {
  final String referenceId;
  final String status;
  final double cashBalance;
  final double totalPortfolioValue;
  final DateTime? lockedPriceUntilUtc;
  final String? invoiceUrl;
  final int? invoiceId;

  const WalletActionExecutionResult({
    required this.referenceId,
    required this.status,
    required this.cashBalance,
    required this.totalPortfolioValue,
    this.lockedPriceUntilUtc,
    this.invoiceUrl,
    this.invoiceId,
  });
}

class InvestorRecipient {
  final int investorUserId;
  final String investorName;
  final String accountNumber;

  const InvestorRecipient({
    required this.investorUserId,
    required this.investorName,
    required this.accountNumber,
  });

  factory InvestorRecipient.fromJson(Map<String, dynamic> json) {
    return InvestorRecipient(
      investorUserId: (json['investorUserId'] as num?)?.toInt() ?? 0,
      investorName: (json['investorName'] ?? '').toString(),
      accountNumber: (json['accountNumber'] ?? '').toString(),
    );
  }
}
