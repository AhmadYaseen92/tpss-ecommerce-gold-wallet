import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/models/wallet_model.dart'
    as wallet_model;
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart'
    as wallet_entity;
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements IWalletRepository {
  WalletRepositoryImpl(this._localDataSource);

  final WalletLocalDataSource _localDataSource;

  @override
  Future<List<wallet_entity.WalletEntity>> loadWallets() async {
    final wallets = await _localDataSource.loadWallets();
    return wallets.map(_toEntity).toList();
  }

  @override
  Stream<List<wallet_entity.WalletEntity>> watchWallets() {
    return _localDataSource.watchWallets().map(
      (wallets) => wallets.map(_toEntity).toList(),
    );
  }

  wallet_entity.WalletEntity _toEntity(wallet_model.WalletModel model) {
    return wallet_entity.WalletEntity(
      category: _toCategory(model.category),
      tabLabel: model.tabLabel,
      walletName: model.walletName,
      isVerified: model.isVerified,
      isComingSoon: model.isComingSoon,
      icon: model.icon,
      totalWeightInGrams: model.totalWeightInGrams,
      totalMarketValue: model.totalMarketValue,
      totalHoldings: model.totalHoldings,
      change: model.change,
      note: model.note,
      transactions: model.transactions.map(_toTransactionEntity).toList(),
    );
  }

  wallet_entity.WalletTransactionEntity _toTransactionEntity(
    wallet_model.WalletTransaction model,
  ) {
    return wallet_entity.WalletTransactionEntity(
      name: model.name,
      category: _toCategory(model.category),
      assetType: _toAssetType(model.assetType),
      subtitle: model.subtitle,
      weightInGrams: model.weightInGrams,
      purity: model.purity,
      quantity: model.quantity,
      marketValue: model.marketValue,
      change: model.change,
      sellerName: model.sellerName,
      isSpotMrOrder: model.isSpotMrOrder,
      imageUrl: model.imageUrl,
      certificateUrl: model.certificateUrl,
    );
  }

  wallet_entity.WalletCategory _toCategory(wallet_model.WalletCategory category) {
    return wallet_entity.WalletCategory.values[category.index];
  }

  wallet_entity.AssetType _toAssetType(wallet_model.AssetType assetType) {
    return wallet_entity.AssetType.values[assetType.index];
  }
}
