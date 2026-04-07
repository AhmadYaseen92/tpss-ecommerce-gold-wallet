import 'package:tpss_ecommerce_gold_wallet/features/transfer/domain/repositories/transfer_repository.dart';

class VerifyTransferAccountUseCase {
  const VerifyTransferAccountUseCase(this._repository);

  final ITransferRepository _repository;

  Future<bool> call(String accountNumber) {
    return _repository.isRegisteredAccount(accountNumber);
  }
}
