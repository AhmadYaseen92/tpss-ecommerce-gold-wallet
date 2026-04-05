import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/datasources/wallet_action_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/repositories/wallet_action_repository.dart';

class WalletActionRepositoryImpl implements WalletActionRepository {
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
}
