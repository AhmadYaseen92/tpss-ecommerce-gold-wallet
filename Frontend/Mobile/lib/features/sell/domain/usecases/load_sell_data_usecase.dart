import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/repositories/sell_repository.dart';

class LoadSellDataUseCase {
  const LoadSellDataUseCase(this._repository);

  final ISellRepository _repository;

  Future<void> call() => _repository.warmup();
}
