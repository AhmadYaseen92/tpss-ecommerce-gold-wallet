import 'package:flutter/material.dart';

enum WalletCategory { gold, silver, diamond, jewelry, coins, spotMr }

enum AssetType { bar, gram, ounce, coin, necklace, ring, bracelet }

class WalletModel {
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

  final List<WalletTransaction> transactions;

  const WalletModel({
    required this.category,
    required this.tabLabel,
    required this.walletName,
    required this.isVerified,
    this.isComingSoon = false,
    required this.icon,
    required this.totalWeightInGrams,
    required this.totalMarketValue,
    required this.totalHoldings,
    required this.change,
    this.note,
    required this.transactions,
  });

  double get totalWeightInKg => totalWeightInGrams / 1000;
  double get totalWeightInOz => totalWeightInGrams / 31.1035;

  WalletModel copyWith({
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
    List<WalletTransaction>? transactions,
  }) {
    return WalletModel(
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

class WalletTransaction {
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

  const WalletTransaction({
    required this.name,
    required this.category,
    required this.assetType,
    required this.subtitle,
    required this.weightInGrams,
    required this.purity,
    required this.quantity,
    required this.marketValue,
    required this.change,
    this.sellerName = 'Imseeh',
    this.isSpotMrOrder = false,
    required this.imageUrl,
    this.certificateUrl,
  });

  double get weightInKg => weightInGrams / 1000;
  double get weightInOz => weightInGrams / 31.1035;

  double get marketValueAmount => _parseCurrency(marketValue);

  /// e.g. '+1.8%' => 1.8, '-0.3%' => -0.3
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

  WalletTransaction copyWith({
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
    return WalletTransaction(
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

final List<WalletModel> dummyWallets = [
  WalletModel(
    category: WalletCategory.gold,
    tabLabel: 'Gold',
    walletName: 'Gold Wallet',
    isVerified: true,
    icon: Icons.diamond_rounded,
    totalWeightInGrams: 5113.31,
    totalMarketValue: '\$345,200.00',
    totalHoldings: 3,
    change: '+1.8%',
    transactions: [
      WalletTransaction(
        name: 'Gold Bar 5 KG',
        category: WalletCategory.gold,
        assetType: AssetType.bar,
        subtitle: '1 item • 5000 g',
        weightInGrams: 5000,
        purity: '999.9',
        quantity: 1,
        marketValue: '\$337,000.00',
        change: '+1.6%',
        sellerName: 'Imseeh',
        imageUrl:
            'https://bfasset.costco-static.com/U447IH35/as/9tnb5fqxj5gtkn5sg8jrh/4000364603-894__1?auto=webp&format=jpg&width=600',
      ),

      WalletTransaction(
        name: 'Gold Coins',
        category: WalletCategory.gold,
        assetType: AssetType.coin,
        subtitle: '12 coins • 93.31 g',
        weightInGrams: 93.31,
        purity: '916',
        quantity: 12,
        marketValue: '\$6,500.00',
        change: '+2.2%',
        sellerName: 'Sakkejha',
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMuutlptbB5vglIH1XrZZaI8nRKwO_Z_zr3g&s',
      ),

      WalletTransaction(
        name: 'Gold Gram Bars',
        category: WalletCategory.gold,
        assetType: AssetType.gram,
        subtitle: '20 pieces • 20 g',
        weightInGrams: 20,
        purity: '999.9',
        quantity: 20,
        marketValue: '\$1,700.00',
        change: '+1.3%',
        sellerName: 'Da’naa',
        imageUrl:
            'https://images.unsplash.com/photo-1610375461246-83df859d849d?q=80&w=800',
      ),

      WalletTransaction(
        name: 'Gold Ounce Bar',
        category: WalletCategory.gold,
        assetType: AssetType.ounce,
        subtitle: '2 bars • 62.2 g',
        weightInGrams: 62.2,
        purity: '999.9',
        quantity: 2,
        marketValue: '\$5,000.00',
        change: '+1.5%',
        sellerName: 'Imseeh',
        imageUrl:
            'https://images.unsplash.com/photo-1610375461246-83df859d849d?q=80&w=800',
      ),
    ],
  ),
  WalletModel(
    category: WalletCategory.silver,
    tabLabel: 'Silver',
    walletName: 'Silver Wallet',
    isVerified: true,
    icon: Icons.diamond_outlined,
    totalWeightInGrams: 1450,
    totalMarketValue: '\$1,160.00',
    totalHoldings: 2,
    change: '+0.9%',
    transactions: [
      WalletTransaction(
        name: 'Silver Bars',
        category: WalletCategory.silver,
        assetType: AssetType.bar,
        subtitle: '3 bars • 850 g',
        weightInGrams: 850,
        purity: '999',
        quantity: 3,
        marketValue: '\$680.00',
        change: '+0.9%',
        imageUrl:
            'https://www.pamp.com/sites/pamp/files/2024-10/pamp-1oz-silver-bar-usa-webimage-1000x1000px-obv.png',
      ),

      WalletTransaction(
        name: 'Silver Coins',
        category: WalletCategory.silver,
        assetType: AssetType.coin,
        subtitle: '20 coins • 600 g',
        weightInGrams: 600,
        purity: '999',
        quantity: 20,
        marketValue: '\$480.00',
        change: '-0.3%',
        imageUrl:
            'https://static.jmbullion.com/image/upload/q_auto,f_auto,w_202,h_202/v1761337031/SRSUNMERCURY1_4_obverse',
      ),

      WalletTransaction(
        name: 'Silver Ounce Rounds',
        category: WalletCategory.silver,
        assetType: AssetType.ounce,
        subtitle: '10 rounds • 311 g',
        weightInGrams: 311,
        purity: '999',
        quantity: 10,
        marketValue: '\$310.00',
        change: '+0.4%',
        imageUrl:
            'https://static.jmbullion.com/image/upload/q_auto,f_auto,w_202,h_202/v1761337031/SRSUNMERCURY1_4_obverse',
      ),

      WalletTransaction(
        name: 'Silver Gram Bars',
        category: WalletCategory.silver,
        assetType: AssetType.gram,
        subtitle: '50 pieces • 50 g',
        weightInGrams: 50,
        purity: '999',
        quantity: 50,
        marketValue: '\$45.00',
        change: '+0.2%',
        imageUrl:
            'https://www.pamp.com/sites/pamp/files/2024-10/pamp-1oz-silver-bar-usa-webimage-1000x1000px-obv.png',
      ),
    ],
  ),
  WalletModel(
    category: WalletCategory.jewelry,
    tabLabel: 'Jewelry',
    walletName: 'Jewelry Wallet',
    isVerified: false,
    icon: Icons.auto_awesome,
    totalWeightInGrams: 42,
    totalMarketValue: '\$3,200.00',
    totalHoldings: 3,
    change: '+3.1%',
    transactions: [
      WalletTransaction(
        name: 'Gold Necklace',
        category: WalletCategory.jewelry,
        assetType: AssetType.necklace,
        subtitle: '1 piece • 18 g',
        weightInGrams: 18,
        purity: '18K',
        quantity: 1,
        marketValue: '\$1,400.00',
        change: '+4.2%',
        imageUrl:
            'https://www.baublebar.com/cdn/shop/files/64317_G_01.jpg?v=1746637318&width=1512',
      ),

      WalletTransaction(
        name: 'Emerald Ring',
        category: WalletCategory.jewelry,
        assetType: AssetType.ring,
        subtitle: '2 rings • 12 g',
        weightInGrams: 12,
        purity: '18K',
        quantity: 2,
        marketValue: '\$950.00',
        change: '+2.0%',
        imageUrl:
            'https://glennbradford.com/cdn/shop/products/EmeraldAndDiamondRing-singleweb_540x.jpg?v=1616012868',
      ),

      WalletTransaction(
        name: 'Gold Bracelet',
        category: WalletCategory.jewelry,
        assetType: AssetType.bracelet,
        subtitle: '1 piece • 12 g',
        weightInGrams: 12,
        purity: '21K',
        quantity: 1,
        marketValue: '\$850.00',
        change: '+1.4%',
        imageUrl:
            'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=800',
      ),

      WalletTransaction(
        name: 'Diamond Earrings',
        category: WalletCategory.jewelry,
        assetType: AssetType.ring,
        subtitle: '1 pair • 5 g',
        weightInGrams: 5,
        purity: '18K',
        quantity: 1,
        marketValue: '\$720.00',
        change: '+1.1%',
        imageUrl:
            'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?q=80&w=800',
      ),
    ],
  ),
  WalletModel(
    category: WalletCategory.coins,
    tabLabel: 'Coins',
    walletName: 'Coin Holdings',
    isVerified: true,
    icon: Icons.monetization_on,
    totalWeightInGrams: 693.31,
    totalMarketValue: '\$6,980.00',
    totalHoldings: 32,
    change: '+1.4%',
    note:
        'Includes gold and silver coin holdings already counted in their main wallets.',
    transactions: [
      WalletTransaction(
        name: 'Gold Coins',
        category: WalletCategory.gold,
        assetType: AssetType.coin,
        subtitle: '12 coins • 93.31 g',
        weightInGrams: 93.31,
        purity: '916',
        quantity: 12,
        marketValue: '\$6,500.00',
        change: '+2.2%',
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMuutlptbB5vglIH1XrZZaI8nRKwO_Z_zr3g&s',
      ),

      WalletTransaction(
        name: 'Silver Coins',
        category: WalletCategory.silver,
        assetType: AssetType.coin,
        subtitle: '20 coins • 600 g',
        weightInGrams: 600,
        purity: '999',
        quantity: 20,
        marketValue: '\$480.00',
        change: '-0.3%',
        imageUrl:
            'https://static.jmbullion.com/image/upload/q_auto,f_auto,w_202,h_202/v1761337031/SRSUNMERCURY1_4_obverse',
      ),

      WalletTransaction(
        name: 'Commemorative Coin',
        category: WalletCategory.gold,
        assetType: AssetType.coin,
        subtitle: '1 coin • 31 g',
        weightInGrams: 31,
        purity: '999',
        quantity: 1,
        marketValue: '\$2,000.00',
        change: '+3.1%',
        imageUrl:
            'https://images.unsplash.com/photo-1610375461246-83df859d849d?q=80&w=800',
      ),
    ],
  ),
  WalletModel(
    category: WalletCategory.spotMr,
    tabLabel: 'Spot MR',
    walletName: 'Spot MR Orders',
    isVerified: true,
    icon: Icons.show_chart,
    totalWeightInGrams: 0,
    totalMarketValue: '\$0.00',
    totalHoldings: 0,
    change: '+0.0%',
    note: 'Contains all market watch buy orders.',
    transactions: const [],
  ),
];
