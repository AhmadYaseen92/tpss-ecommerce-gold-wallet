import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';

class FilterCartItemsUseCase {
  const FilterCartItemsUseCase();

  List<CartItemEntity> call({
    required List<CartItemEntity> items,
    required String sellerFilter,
  }) {
    return items.where((item) => AppReleaseConfig.matchesSeller(sellerFilter, item.sellerName)).toList();
  }
}
