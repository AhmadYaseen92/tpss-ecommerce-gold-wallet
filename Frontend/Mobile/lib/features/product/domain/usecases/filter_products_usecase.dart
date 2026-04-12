import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';

class FilterProductsUseCase {
  const FilterProductsUseCase();

  List<ProductEntity> call({
    required List<ProductEntity> products,
    required int? categoryId,
    required String seller,
  }) {
    return products.where((product) {
      final categoryOk =
          categoryId == null || product.categoryId == categoryId;
      final sellerOk = AppReleaseConfig.matchesSeller(seller, product.sellerName);
      return categoryOk && sellerOk;
    }).toList();
  }
}
