import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';

class FilterProductsUseCase {
  const FilterProductsUseCase();

  List<ProductEntity> call({
    required List<ProductEntity> products,
    required String category,
    required String seller,
  }) {
    return products.where((product) {
      final categoryOk = category == 'All' || product.category == category;
      final sellerOk = AppReleaseConfig.matchesSeller(seller, product.sellerName);
      return categoryOk && sellerOk;
    }).toList();
  }
}
