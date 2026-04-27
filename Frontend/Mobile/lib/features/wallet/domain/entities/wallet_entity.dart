import 'package:flutter/material.dart';

enum WalletCategory { gold, silver, diamond, jewelry, coins, spotMr }

enum AssetType { bar, gram, ounce, coin, necklace, ring, bracelet }

class WalletEntity {
  const WalletEntity({
    required this.category,
    required this.tabLabel,
    required this.walletName,
    required this.isVerified,
    required this.icon,
    required this.totalWeightInGrams,
    required this.totalMarketValue,
    required this.cashBalance,
    required this.totalHoldings,
    required this.change,
    required this.transactions,
    this.isComingSoon = false,
    this.note,
  });

  final WalletCategory category;
  final String tabLabel;
  final String walletName;
  final bool isVerified;
  final bool isComingSoon;
  final IconData icon;

  final double totalWeightInGrams;
  final String totalMarketValue;
  final String cashBalance;
  final int totalHoldings;
  final String change;
  final String? note;
  final List<WalletTransactionEntity> transactions;

  double get totalWeightInKg => totalWeightInGrams / 1000;
  double get totalWeightInOz => totalWeightInGrams / 31.1035;

  WalletEntity copyWith({
    WalletCategory? category,
    String? tabLabel,
    String? walletName,
    bool? isVerified,
    bool? isComingSoon,
    IconData? icon,
    double? totalWeightInGrams,
    String? totalMarketValue,
    String? cashBalance,
    int? totalHoldings,
    String? change,
    String? note,
    List<WalletTransactionEntity>? transactions,
  }) {
    return WalletEntity(
      category: category ?? this.category,
      tabLabel: tabLabel ?? this.tabLabel,
      walletName: walletName ?? this.walletName,
      isVerified: isVerified ?? this.isVerified,
      isComingSoon: isComingSoon ?? this.isComingSoon,
      icon: icon ?? this.icon,
      totalWeightInGrams: totalWeightInGrams ?? this.totalWeightInGrams,
      totalMarketValue: totalMarketValue ?? this.totalMarketValue,
      cashBalance: cashBalance ?? this.cashBalance,
      totalHoldings: totalHoldings ?? this.totalHoldings,
      change: change ?? this.change,
      note: note ?? this.note,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletTransactionEntity {
  const WalletTransactionEntity({
    required this.id,
    required this.name,
    this.productSku,
    required this.category,
    required this.assetType,
    required this.productFormLabel,
    required this.subtitle,
    required this.weightInGrams,
    required this.purity,
    required this.quantity,
    required this.marketValue,
    String? displayValue,
    required this.change,
    required this.investmentValue,
    required this.profitOrLossValue,
    required this.imageUrl,
    this.sellerName = 'Imseeh',
    this.isSpotMrOrder = false,
    this.certificateUrl,
    this.isDelivered = false,
    this.status = 'Bought',
    this.statusDetails,
    this.sourceInvestorName,
  }) : displayValue = displayValue ?? marketValue;

  final int id;
  final String name;
  final String? productSku;
  final WalletCategory category;
  final AssetType assetType;
  final String productFormLabel;
  final String subtitle;
  final double weightInGrams;
  final String purity;
  final int quantity;
  final String marketValue;
  final String displayValue;
  final String change;
  final double investmentValue;
  final double profitOrLossValue;
  final String sellerName;
  final bool isSpotMrOrder;
  final String imageUrl;
  final String? certificateUrl;
  final bool isDelivered;
  final String status;
  final String? statusDetails;
  final String? sourceInvestorName;

  double get weightInKg => weightInGrams / 1000;
  double get weightInOz => weightInGrams / 31.1035;

  double get marketValueAmount => _parseCurrency(marketValue);

  double get changePercent {
    final cleaned = change.replaceAll('%', '').replaceAll('+', '').trim();
    final parsed = double.tryParse(cleaned) ?? 0;
    return change.trim().startsWith('-') ? -parsed : parsed;
  }

  double get estimatedPurchaseValue {
    final denominator = 1 + (changePercent / 100);
    if (denominator == 0) return marketValueAmount;
    return marketValueAmount / denominator;
  }

  double get marketPricePerGram {
    if (weightInGrams == 0) return 0;
    return marketValueAmount / weightInGrams;
  }

  double get actionBaseAmount {
    if (investmentValue > 0) return investmentValue;
    final fromDisplay = _parseCurrency(displayValue);
    if (fromDisplay > 0) return fromDisplay;
    return marketValueAmount;
  }

  double get actionUnitPrice {
    if (quantity <= 0) return 0;
    return actionBaseAmount / quantity;
  }

  WalletTransactionEntity copyWith({
    int? id,
    String? name,
    String? productSku,
    WalletCategory? category,
    AssetType? assetType,
    String? productFormLabel,
    String? subtitle,
    double? weightInGrams,
    String? purity,
    int? quantity,
    String? marketValue,
    String? displayValue,
    String? change,
    double? investmentValue,
    double? profitOrLossValue,
    String? sellerName,
    bool? isSpotMrOrder,
    String? imageUrl,
    String? certificateUrl,
    bool? isDelivered,
    String? status,
    String? statusDetails,
    String? sourceInvestorName,
  }) {
    return WalletTransactionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      productSku: productSku ?? this.productSku,
      category: category ?? this.category,
      assetType: assetType ?? this.assetType,
      productFormLabel: productFormLabel ?? this.productFormLabel,
      subtitle: subtitle ?? this.subtitle,
      weightInGrams: weightInGrams ?? this.weightInGrams,
      purity: purity ?? this.purity,
      quantity: quantity ?? this.quantity,
      marketValue: marketValue ?? this.marketValue,
      displayValue: displayValue ?? this.displayValue,
      change: change ?? this.change,
      investmentValue: investmentValue ?? this.investmentValue,
      profitOrLossValue: profitOrLossValue ?? this.profitOrLossValue,
      sellerName: sellerName ?? this.sellerName,
      isSpotMrOrder: isSpotMrOrder ?? this.isSpotMrOrder,
      imageUrl: imageUrl ?? this.imageUrl,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      isDelivered: isDelivered ?? this.isDelivered,
      status: status ?? this.status,
      statusDetails: statusDetails ?? this.statusDetails,
      sourceInvestorName: sourceInvestorName ?? this.sourceInvestorName,
    );
  }

  double _parseCurrency(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0;
  }
}
