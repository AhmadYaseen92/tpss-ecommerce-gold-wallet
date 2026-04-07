import 'package:flutter/material.dart';

enum WalletCategory { gold, silver, jewelry, coins, spotMr }

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
      totalHoldings: totalHoldings ?? this.totalHoldings,
      change: change ?? this.change,
      note: note ?? this.note,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletTransactionEntity {
  const WalletTransactionEntity({
    required this.name,
    required this.category,
    required this.assetType,
    required this.subtitle,
    required this.weightInGrams,
    required this.purity,
    required this.quantity,
    required this.marketValue,
    required this.change,
    required this.imageUrl,
    this.sellerName = 'Imseeh',
    this.isSpotMrOrder = false,
    this.certificateUrl,
  });

  final String name;
  final WalletCategory category;
  final AssetType assetType;
  final String subtitle;
  final double weightInGrams;
  final String purity;
  final int quantity;
  final String marketValue;
  final String change;
  final String sellerName;
  final bool isSpotMrOrder;
  final String imageUrl;
  final String? certificateUrl;

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

  WalletTransactionEntity copyWith({
    String? name,
    WalletCategory? category,
    AssetType? assetType,
    String? subtitle,
    double? weightInGrams,
    String? purity,
    int? quantity,
    String? marketValue,
    String? change,
    String? sellerName,
    bool? isSpotMrOrder,
    String? imageUrl,
    String? certificateUrl,
  }) {
    return WalletTransactionEntity(
      name: name ?? this.name,
      category: category ?? this.category,
      assetType: assetType ?? this.assetType,
      subtitle: subtitle ?? this.subtitle,
      weightInGrams: weightInGrams ?? this.weightInGrams,
      purity: purity ?? this.purity,
      quantity: quantity ?? this.quantity,
      marketValue: marketValue ?? this.marketValue,
      change: change ?? this.change,
      sellerName: sellerName ?? this.sellerName,
      isSpotMrOrder: isSpotMrOrder ?? this.isSpotMrOrder,
      imageUrl: imageUrl ?? this.imageUrl,
      certificateUrl: certificateUrl ?? this.certificateUrl,
    );
  }

  double _parseCurrency(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0;
  }
}
