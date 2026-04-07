import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartProductQuantityUseCase {
  const UpdateCartProductQuantityUseCase(this._repository);

  final ICartRepository _repository;

  Future<void> call(String id, int quantity) => _repository.updateProductQuantity(id, quantity);
}
