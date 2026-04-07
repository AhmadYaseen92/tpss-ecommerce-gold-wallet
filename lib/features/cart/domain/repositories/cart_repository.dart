import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';

abstract class ICartRepository {
  Future<List<CartItemEntity>> getCartItems();

  Future<void> addProduct(CartItemEntity item);

  Future<void> removeProduct(String id);

  Future<void> updateProductQuantity(String id, int quantity);
}
