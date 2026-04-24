import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/api_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/realtime/realtime_refresh_service.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart'
    as wallet_entity;
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements IWalletRepository {
  WalletRepositoryImpl(this._remoteDataSource, this._realtimeRefreshService);

  final WalletRemoteDataSource _remoteDataSource;
  final RealtimeRefreshService _realtimeRefreshService;

  @override
  Future<List<wallet_entity.WalletEntity>> loadWallets() async {
    final wallet = await _remoteDataSource.getWalletByCurrentUser();
    Map<int, WalletPurchaseSnapshot> snapshots = const {};
    try {
      snapshots = await _remoteDataSource.getLatestApprovedBuySnapshots();
    } catch (_) {
      snapshots = const {};
    }
    return _toWalletEntities(wallet, snapshots);
  }

  @override
  Stream<List<wallet_entity.WalletEntity>> watchWallets() async* {
    await _realtimeRefreshService.ensureStarted();
    yield await loadWallets();

    yield* _realtimeRefreshService.refreshes.asyncMap((_) => loadWallets());
  }

  List<wallet_entity.WalletEntity> _toWalletEntities(
    WalletRemoteModel wallet,
    Map<int, WalletPurchaseSnapshot> snapshots,
  ) {
    final byCategory = <wallet_entity.WalletCategory, List<WalletAssetRemoteModel>>{};
    for (final asset in wallet.assets) {
      final category = _toCategory(asset.category, asset.assetType);
      byCategory.putIfAbsent(category, () => []).add(asset);
    }

    const categories = <wallet_entity.WalletCategory>[
      wallet_entity.WalletCategory.gold,
      wallet_entity.WalletCategory.silver,
      wallet_entity.WalletCategory.diamond,
      wallet_entity.WalletCategory.jewelry,
      wallet_entity.WalletCategory.coins,
      wallet_entity.WalletCategory.spotMr,
    ];

    return categories.map((category) {
      final assets = byCategory[category] ?? const <WalletAssetRemoteModel>[];
      final transactions = assets
          .map((asset) => _toTransactionEntity(category, asset, snapshots[asset.id]))
          .toList();
      final totalWeightInGrams = transactions.fold<double>(0, (sum, tx) => sum + tx.weightInGrams * tx.quantity);
      final totalMarket = transactions.fold<double>(0, (sum, tx) => sum + tx.marketValueAmount);
      final totalBuy = assets.fold<double>(0, (sum, asset) => sum + (asset.averageBuyPrice * asset.quantity));
      final changePercent = totalBuy == 0 ? 0 : ((totalMarket - totalBuy) / totalBuy) * 100;
      final signed = changePercent >= 0 ? '+' : '';
      final isEmptyCategory = transactions.isEmpty;

      return wallet_entity.WalletEntity(
        category: category,
        tabLabel: _tabLabel(category),
        walletName: _walletName(category),
        isVerified: !isEmptyCategory,
        icon: _walletIcon(category),
        totalWeightInGrams: totalWeightInGrams,
        totalMarketValue: '\$${totalMarket.toStringAsFixed(2)}',
        cashBalance: '\$${wallet.cashBalance.toStringAsFixed(2)}',
        totalHoldings: transactions.length,
        change: '$signed${changePercent.toStringAsFixed(2)}%',
        transactions: transactions,
        note: isEmptyCategory
            ? 'No assets yet. Buy items from Product and start investing to build this wallet section.'
            : null,
      );
    }).toList();
  }

  wallet_entity.WalletTransactionEntity _toTransactionEntity(
    wallet_entity.WalletCategory category,
    WalletAssetRemoteModel asset,
    WalletPurchaseSnapshot? snapshot,
  ) {
    final totalWeightInGrams = _toGrams(asset.weight, asset.unit) * asset.quantity;
    final liveMarketTotal = asset.currentMarketPrice * asset.quantity;
    final snapshotBuyUnitPriceWithFees = snapshot != null && snapshot.amount > 0 && snapshot.quantity > 0
        ? snapshot.amount / snapshot.quantity
        : 0.0;
    final assetBuyUnitPriceWithFees = asset.acquisitionFinalAmount > 0 && asset.quantity > 0
        ? asset.acquisitionFinalAmount / asset.quantity
        : 0.0;
    final buyUnitPriceWithFees = snapshotBuyUnitPriceWithFees > 0
        ? snapshotBuyUnitPriceWithFees
        : assetBuyUnitPriceWithFees;
    final totalValue = buyUnitPriceWithFees > 0
        ? buyUnitPriceWithFees * asset.quantity
        : liveMarketTotal;
    final totalBuy = asset.averageBuyPrice * asset.quantity;
    final changePercent = totalBuy == 0 ? 0 : ((totalValue - totalBuy) / totalBuy) * 100;
    final signed = changePercent >= 0 ? '+' : '';
    final profitOrLossValue = totalValue - totalBuy;
    final resolvedName = snapshot?.productName.trim().isNotEmpty == true
        ? snapshot!.productName.trim()
        : asset.productName.trim().isNotEmpty
        ? asset.productName.trim()
        : (asset.productSku?.trim().isNotEmpty ?? false)
        ? asset.productSku!.trim()
        : _toDisplayName(asset.assetType);
    final purchaseValue = buyUnitPriceWithFees > 0
        ? buyUnitPriceWithFees * asset.quantity
        : totalBuy;

    return wallet_entity.WalletTransactionEntity(
      id: asset.id,
      name: resolvedName,
      productSku: asset.productSku,
      category: category,
      assetType: _toAssetType(asset.assetType),
      subtitle: asset.productSku?.trim().isNotEmpty == true ? 'SKU: ${asset.productSku!.trim()}' : _toDisplayName(asset.assetType),
      weightInGrams: totalWeightInGrams,
      purity: _formatPurity(
        snapshot != null && snapshot.purity > 0 ? snapshot.purity : asset.purity,
      ),
      quantity: asset.quantity,
      marketValue: '\$${totalValue.toStringAsFixed(2)}',
      displayValue: '\$${purchaseValue.toStringAsFixed(2)}',
      change: '$signed${changePercent.toStringAsFixed(2)}%',
      investmentValue: purchaseValue,
      profitOrLossValue: profitOrLossValue,
      imageUrl: asset.productImageUrl?.trim().isNotEmpty == true
          ? asset.productImageUrl!.trim()
          : _imageByAssetMeta(assetType: asset.assetType, category: asset.category, productName: resolvedName),
      sellerName: asset.sellerName.isEmpty ? 'Unknown Seller' : asset.sellerName,
      certificateUrl: asset.certificateUrl,
      isDelivered: asset.isDelivered,
      status: asset.status,
      statusDetails: asset.statusDetails,
      sourceInvestorName: asset.sourceInvestorName,
    );
  }

  String _toDisplayName(String assetType) {
    final normalized = assetType.trim();
    if (normalized.isEmpty) return 'Wallet Item';
    final withSpaces = normalized.replaceAll(RegExp(r'[_-]+'), ' ');
    return withSpaces
        .split(' ')
        .where((token) => token.trim().isNotEmpty)
        .map((token) => token[0].toUpperCase() + token.substring(1).toLowerCase())
        .join(' ');
  }

  double _toGrams(double weight, String unit) {
    final normalized = unit.toLowerCase();
    if (normalized.contains('kg')) return weight * 1000;
    if (normalized.contains('oz')) return weight * 31.1035;
    return weight;
  }

  wallet_entity.WalletCategory _toCategory(String category, String assetType) {
    final categoryValue = category.toLowerCase();
    if (categoryValue.contains('silver')) return wallet_entity.WalletCategory.silver;
    if (categoryValue.contains('diamond')) return wallet_entity.WalletCategory.diamond;
    if (categoryValue.contains('jewel')) return wallet_entity.WalletCategory.jewelry;
    if (categoryValue.contains('coin')) return wallet_entity.WalletCategory.coins;

    final value = assetType.toLowerCase();
    if (value.contains('diamond')) return wallet_entity.WalletCategory.diamond;
    if (value.contains('silver')) return wallet_entity.WalletCategory.silver;
    if (value.contains('jewel')) return wallet_entity.WalletCategory.jewelry;
    if (value.contains('coin')) return wallet_entity.WalletCategory.coins;
    if (value.contains('spot')) return wallet_entity.WalletCategory.spotMr;
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

  String _formatPurity(double value) {
    if (value <= 0) return 'N/A';
    if (value <= 24) {
      final karat = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
      return '${karat}K';
    }
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  String _tabLabel(wallet_entity.WalletCategory category) => switch (category) {
        wallet_entity.WalletCategory.gold => 'Gold',
        wallet_entity.WalletCategory.silver => 'Silver',
        wallet_entity.WalletCategory.diamond => 'Diamond',
        wallet_entity.WalletCategory.jewelry => 'Jewelry',
        wallet_entity.WalletCategory.coins => 'Coins',
        wallet_entity.WalletCategory.spotMr => 'Spot MR',
      };

  String _walletName(wallet_entity.WalletCategory category) => '${_tabLabel(category)} Wallet';

  IconData _walletIcon(wallet_entity.WalletCategory category) => switch (category) {
        wallet_entity.WalletCategory.gold => Icons.workspace_premium_rounded,
        wallet_entity.WalletCategory.silver => Icons.shield_moon_rounded,
        wallet_entity.WalletCategory.diamond => Icons.diamond_rounded,
        wallet_entity.WalletCategory.jewelry => Icons.diamond_outlined,
        wallet_entity.WalletCategory.coins => Icons.monetization_on_outlined,
        wallet_entity.WalletCategory.spotMr => Icons.show_chart_rounded,
      };

  String _imageByAssetMeta({required String assetType, required String category, required String productName}) {
    final descriptor = '${assetType.toLowerCase()} ${category.toLowerCase()} ${productName.toLowerCase()}';
    if (descriptor.contains('jewel') || descriptor.contains('ring') || descriptor.contains('bracelet') || descriptor.contains('necklace')) {
      return _serverImage('/images/products/jewelry.jpg');
    }
    if (descriptor.contains('silver')) {
      return _serverImage('/images/products/silver.png');
    }
    if (descriptor.contains('coin')) {
      return _serverImage('/images/products/gold-coin.jpg');
    }
    return _serverImage('/images/products/gold-bar.png');
  }

  String _serverImage(String path) {
    final apiBase = Uri.tryParse(ApiConfig.baseUrl);
    if (apiBase == null) return path;
    final origin = '${apiBase.scheme}://${apiBase.host}${apiBase.hasPort ? ':${apiBase.port}' : ''}';
    return '$origin$path';
  }
}
