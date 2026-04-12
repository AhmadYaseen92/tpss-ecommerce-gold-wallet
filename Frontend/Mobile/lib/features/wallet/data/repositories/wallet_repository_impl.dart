import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart'
    as wallet_entity;
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements IWalletRepository {
  WalletRepositoryImpl(this._remoteDataSource);

  final WalletRemoteDataSource _remoteDataSource;

  @override
  Future<List<wallet_entity.WalletEntity>> loadWallets() async {
    final wallet = await _remoteDataSource.getWalletByCurrentUser();
    return _toWalletEntities(wallet);
  }

  @override
  Stream<List<wallet_entity.WalletEntity>> watchWallets() async* {
    yield await loadWallets();
    yield* Stream.periodic(const Duration(seconds: 20)).asyncMap((_) => loadWallets());
  }

  List<wallet_entity.WalletEntity> _toWalletEntities(WalletRemoteModel wallet) {
    final byCategory = <wallet_entity.WalletCategory, List<WalletAssetRemoteModel>>{};
    for (final asset in wallet.assets) {
      final category = _toCategory(asset.assetType);
      byCategory.putIfAbsent(category, () => []).add(asset);
    }

    return byCategory.entries.map((entry) {
      final category = entry.key;
      final assets = entry.value;
      final transactions = assets.map((asset) => _toTransactionEntity(category, asset)).toList();
      final totalWeightInGrams = transactions.fold<double>(0, (sum, tx) => sum + tx.weightInGrams * tx.quantity);
      final totalMarket = transactions.fold<double>(0, (sum, tx) => sum + tx.marketValueAmount);
      final totalBuy = assets.fold<double>(0, (sum, asset) => sum + (asset.averageBuyPrice * asset.quantity));
      final changePercent = totalBuy == 0 ? 0 : ((totalMarket - totalBuy) / totalBuy) * 100;
      final signed = changePercent >= 0 ? '+' : '';

      return wallet_entity.WalletEntity(
        category: category,
        tabLabel: _tabLabel(category),
        walletName: _walletName(category),
        isVerified: true,
        icon: _walletIcon(category),
        totalWeightInGrams: totalWeightInGrams,
        totalMarketValue: '\$${totalMarket.toStringAsFixed(2)}',
        cashBalance: '\$${wallet.cashBalance.toStringAsFixed(2)}',
        totalHoldings: transactions.length,
        change: '$signed${changePercent.toStringAsFixed(2)}%',
        transactions: transactions,
      );
    }).toList();
  }

  wallet_entity.WalletTransactionEntity _toTransactionEntity(
    wallet_entity.WalletCategory category,
    WalletAssetRemoteModel asset,
  ) {
    final totalValue = asset.currentMarketPrice * asset.quantity;
    final totalBuy = asset.averageBuyPrice * asset.quantity;
    final changePercent = totalBuy == 0 ? 0 : ((totalValue - totalBuy) / totalBuy) * 100;
    final signed = changePercent >= 0 ? '+' : '';

    return wallet_entity.WalletTransactionEntity(
      name: asset.assetType,
      category: category,
      assetType: _toAssetType(asset.assetType),
      subtitle: '${asset.purity.toStringAsFixed(1)} purity',
      weightInGrams: _toGrams(asset.weight, asset.unit),
      purity: asset.purity.toStringAsFixed(2),
      quantity: asset.quantity,
      marketValue: '\$${totalValue.toStringAsFixed(2)}',
      change: '$signed${changePercent.toStringAsFixed(2)}%',
      imageUrl: _imageByAssetType(asset.assetType),
      sellerName: asset.sellerName.isEmpty ? 'Unknown Seller' : asset.sellerName,
    );
  }

  double _toGrams(double weight, String unit) {
    final normalized = unit.toLowerCase();
    if (normalized.contains('kg')) return weight * 1000;
    if (normalized.contains('oz')) return weight * 31.1035;
    return weight;
  }

  wallet_entity.WalletCategory _toCategory(String assetType) {
    final value = assetType.toLowerCase();
    if (value.contains('silver')) return wallet_entity.WalletCategory.silver;
    if (value.contains('jewel')) return wallet_entity.WalletCategory.jewelry;
    if (value.contains('coin')) return wallet_entity.WalletCategory.coins;
    return wallet_entity.WalletCategory.gold;
  }

  wallet_entity.AssetType _toAssetType(String assetType) {
    final value = assetType.toLowerCase();
    if (value.contains('coin')) return wallet_entity.AssetType.coin;
    if (value.contains('ounce')) return wallet_entity.AssetType.ounce;
    if (value.contains('gram')) return wallet_entity.AssetType.gram;
    if (value.contains('necklace')) return wallet_entity.AssetType.necklace;
    if (value.contains('ring')) return wallet_entity.AssetType.ring;
    if (value.contains('bracelet')) return wallet_entity.AssetType.bracelet;
    return wallet_entity.AssetType.bar;
  }

  String _tabLabel(wallet_entity.WalletCategory category) => switch (category) {
        wallet_entity.WalletCategory.gold => 'Gold',
        wallet_entity.WalletCategory.silver => 'Silver',
        wallet_entity.WalletCategory.jewelry => 'Jewelry',
        wallet_entity.WalletCategory.coins => 'Coins',
        wallet_entity.WalletCategory.spotMr => 'Spot MR',
      };

  String _walletName(wallet_entity.WalletCategory category) => '${_tabLabel(category)} Wallet';

  IconData _walletIcon(wallet_entity.WalletCategory category) => switch (category) {
        wallet_entity.WalletCategory.gold => Icons.workspace_premium_rounded,
        wallet_entity.WalletCategory.silver => Icons.shield_moon_rounded,
        wallet_entity.WalletCategory.jewelry => Icons.diamond_outlined,
        wallet_entity.WalletCategory.coins => Icons.monetization_on_outlined,
        wallet_entity.WalletCategory.spotMr => Icons.show_chart_rounded,
      };

  String _imageByAssetType(String assetType) {
    final value = assetType.toLowerCase();
    if (value.contains('silver')) {
      return 'https://www.pamp.com/sites/pamp/files/2024-10/pamp-1oz-silver-bar-usa-webimage-1000x1000px-obv.png';
    }
    return 'https://www.pamp.com/sites/pamp/files/2022-02/10g_1.png';
  }
}
