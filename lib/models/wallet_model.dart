import 'package:flutter/material.dart';

class WalletModel {
  final String tabLabel;
  final String walletName;
  final bool isVerified;
  final bool isComingSoon;
  final String weight;
  final String weightLabel;
  final String value;
  final String change;
  final IconData icon;
  final List<WalletTransaction> transactions;

  const WalletModel({
    required this.tabLabel,
    required this.walletName,
    required this.isVerified,
    this.isComingSoon = false,
    required this.weight,
    required this.weightLabel,
    required this.value,
    required this.change,
    required this.icon,
    required this.transactions,
  });
}

class WalletTransaction {
  final String name;
  final String subtitle;
  final String value;
  final String change;
  final String imageUrl;

  const WalletTransaction({
    required this.name,
    required this.subtitle,
    required this.value,
    required this.change,
    required this.imageUrl,
  });
}

List<WalletModel> dummyWallets = [
  WalletModel(
    tabLabel: 'Gold',
    walletName: 'Gold Wallet',
    isVerified: true,
    weight: '150g',
    weightLabel: 'held in vault',
    value: '\$9,800.00 USD',
    change: '-1.2%',
    icon: Icons.diamond_rounded,
    transactions: [
      WalletTransaction(
        name: 'Gold Bars (1oz)',
        subtitle: '5 units • 150g',
        value: '\$9,800.00',
        change: '+2.5%',
        imageUrl:
            'https://bfasset.costco-static.com/U447IH35/as/9tnb5fqxj5gtkn5sg8jrh/4000364603-894__1?auto=webp&format=jpg&width=600&height=600&fit=bounds&canvas=600,600',
      ),
      WalletTransaction(
        name: 'Gold Coins',
        subtitle: '12 units • 360g',
        value: '\$23,520.00',
        change: '+1.8%',
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMuutlptbB5vglIH1XrZZaI8nRKwO_Z_zr3g&s',
      ),
    ],
  ),
  WalletModel(
    tabLabel: 'Silver',
    walletName: 'Silver Wallet',
    isVerified: true,
    weight: '850g',
    weightLabel: 'held in vault',
    value: '\$680.00 USD',
    change: '+0.9%',
    icon: Icons.diamond_outlined,
    transactions: [
      WalletTransaction(
        name: 'Silver Bars (10oz)',
        subtitle: '3 units • 850g',
        value: '\$680.00',
        change: '+0.9%',
        imageUrl:
        'https://www.pamp.com/sites/pamp/files/2024-10/pamp-1oz-silver-bar-usa-webimage-1000x1000px-obv.png',
      ),
      WalletTransaction(
        name: 'Silver Coins',
        subtitle: '20 units • 600g',
        value: '\$480.00',
        change: '-0.3%',
        imageUrl:
             'https://static.jmbullion.com/image/upload/q_auto,f_auto,w_202,h_202/v1761337031/SRSUNMERCURY1_4_obverse',
      ),
    ],
  ),
  WalletModel(
    tabLabel: 'Jewelry',
    walletName: 'Jewelry Wallet',
    isVerified: false,
    weight: '42g',
    weightLabel: 'in collection',
    value: '\$3,200.00 USD',
    change: '+3.1%',
    icon: Icons.auto_awesome,
    transactions: [
      WalletTransaction(
        name: 'Gold Necklace',
        subtitle: '1 unit • 18g',
        value: '\$1,400.00',
        change: '+4.2%',
        imageUrl:
            'https://www.baublebar.com/cdn/shop/files/64317_G_01.jpg?v=1746637318&width=1512',
      ),
      WalletTransaction(
        name: 'Emerald Ring',
        subtitle: '2 units • 12g',
        value: '\$950.00',
        change: '+2.0%',
        imageUrl:
        'https://glennbradford.com/cdn/shop/products/EmeraldAndDiamondRing-singleweb_540x.jpg?v=1616012868',
      ),
    ],
  ),
  WalletModel(
    tabLabel: 'Coins',
    walletName: 'Coins Wallet',
    isVerified: false,
    isComingSoon: true,
    weight: '0.00',
    weightLabel: 'coming soon',
    value: '\$0.00 USD',
    change: '+0.0%',
    icon: Icons.monetization_on,
    transactions: [],
  ),
];
