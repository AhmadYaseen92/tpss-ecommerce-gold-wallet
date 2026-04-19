import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/datasources/wallet_action_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/repositories/wallet_action_repository.dart';

class WalletActionRepositoryImpl implements IWalletActionRepository {
  WalletActionRepositoryImpl(this._remoteDataSource);

  final WalletActionRemoteDataSource _remoteDataSource;

  @override
  Future<bool> isMarketOpen() {
    return _remoteDataSource.isMarketOpen();
  }

  @override
  Future<double> availableLiquidity() {
    return _remoteDataSource.availableLiquidity();
  }

  @override
  Future<double> lockUnitPrice(double requestedUnitPrice) {
    return _remoteDataSource.lockUnitPrice(requestedUnitPrice);
  }

  @override
  Future<SellExecutionMode> getSellExecutionMode() {
    return _remoteDataSource.getSellExecutionMode();
  }

  @override
  Future<WalletActionExecutionResult> executeWalletAction(WalletActionExecutionRequest request) {
    return _remoteDataSource.executeWalletAction(request);
  }

  @override
  Future<void> cancelWalletRequest({required int walletAssetId}) {
    return _remoteDataSource.cancelWalletRequest(walletAssetId: walletAssetId);
  }

  @override
  Future<List<InvestorRecipient>> searchInvestors(String query) {
    return _remoteDataSource.searchInvestors(query);
  }

  @override
  Future<InvestorRecipient?> lookupInvestor(String accountNumber) {
    return _remoteDataSource.lookupInvestor(accountNumber);
  }
}
