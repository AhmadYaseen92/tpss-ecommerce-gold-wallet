import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';

class GetAvailableSellersUseCase {
  const GetAvailableSellersUseCase();

  List<String> call(List<CartItemEntity> items) {
    final sellers = items.map((p) => p.sellerName).toSet().toList()..sort();
    return sellers;
  }
}
