import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/repositories/cart_repository.dart';

class GetCartItemsUseCase {
  const GetCartItemsUseCase(this._repository);

  final ICartRepository _repository;

  Future<List<CartItemEntity>> call() => _repository.getCartItems();
}
