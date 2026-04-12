import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';

class FilterProductsUseCase {
  const FilterProductsUseCase();

  static const Set<int> _bullionCategoryIds = {0, 1, 2, 3, 10};
  static const Set<int> _coinCategoryIds = {4, 5, 6};
  static const Set<int> _jewelleryCategoryIds = {7, 8, 9};

  List<ProductEntity> call({
    required List<ProductEntity> products,
    required int? categoryId,
    required String seller,
  }) {
    return products.where((product) {
      final categoryOk = switch (categoryId) {
        null => true,
        3 => _bullionCategoryIds.contains(product.categoryId),
        4 => _coinCategoryIds.contains(product.categoryId),
        7 => _jewelleryCategoryIds.contains(product.categoryId),
        _ => product.categoryId == categoryId,
      };
      final sellerOk = AppReleaseConfig.matchesSeller(seller, product.sellerName);
      return categoryOk && sellerOk;
    }).toList();
  }
}
