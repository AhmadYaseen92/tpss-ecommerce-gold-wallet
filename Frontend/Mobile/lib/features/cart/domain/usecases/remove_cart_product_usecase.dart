import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/repositories/cart_repository.dart';

class RemoveCartProductUseCase {
  const RemoveCartProductUseCase(this._repository);

  final ICartRepository _repository;

  Future<void> call(String id) => _repository.removeProduct(id);
}
