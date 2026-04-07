import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/repositories/cart_repository.dart';

class AddCartProductUseCase {
  const AddCartProductUseCase(this._repository);

  final ICartRepository _repository;

  Future<void> call(CartItemEntity item) => _repository.addProduct(item);
}
