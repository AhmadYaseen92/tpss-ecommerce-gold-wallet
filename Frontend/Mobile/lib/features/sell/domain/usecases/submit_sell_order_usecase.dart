import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/repositories/sell_repository.dart';

class SubmitSellOrderUseCase {
  const SubmitSellOrderUseCase(this._repository);

  final ISellRepository _repository;

  Future<void> call() => _repository.submitSellOrder();
}
