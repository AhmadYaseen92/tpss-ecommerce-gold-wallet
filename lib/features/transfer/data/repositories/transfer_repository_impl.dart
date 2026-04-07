import 'package:tpss_ecommerce_gold_wallet/features/transfer/data/datasources/transfer_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/domain/repositories/transfer_repository.dart';

class TransferRepositoryImpl implements ITransferRepository {
  TransferRepositoryImpl(this._localDataSource);

  final TransferLocalDataSource _localDataSource;

  @override
  Future<bool> isRegisteredAccount(String accountNumber) {
    return _localDataSource.isRegisteredAccount(accountNumber);
  }
}
