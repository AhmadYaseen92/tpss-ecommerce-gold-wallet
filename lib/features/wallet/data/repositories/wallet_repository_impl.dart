import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/models/wallet_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements IWalletRepository {
  WalletRepositoryImpl(this._localDataSource);

  final WalletLocalDataSource _localDataSource;

  @override
  Future<List<WalletEntity>> loadWallets() async {
    final wallets = await _localDataSource.loadWallets();
    return wallets.map(_toEntity).toList();
  }

  @override
  Stream<List<WalletEntity>> watchWallets() {
    return _localDataSource.watchWallets().map(
      (wallets) => wallets.map(_toEntity).toList(),
    );
  }

  WalletEntity _toEntity(WalletModel model) {
    return WalletEntity(
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

  WalletTransactionEntity _toTransactionEntity(WalletTransaction model) {
    return WalletTransactionEntity(
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

  WalletCategory _toCategory(dynamic category) {
    return WalletCategory.values[category.index as int];
  }

  AssetType _toAssetType(dynamic assetType) {
    return AssetType.values[assetType.index as int];
  }
}
