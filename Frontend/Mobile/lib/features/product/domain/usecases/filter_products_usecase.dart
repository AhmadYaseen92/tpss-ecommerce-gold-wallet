import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/product_form_filter.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';

class FilterProductsUseCase {
  const FilterProductsUseCase();

  List<ProductEntity> call({
    required List<ProductEntity> products,
    required int? categoryId,
    required String seller,
    required String formLabel,
  }) {
    return products.where((product) {
      final categoryOk =
          categoryId == null || product.categoryId == categoryId;
      final sellerOk = AppReleaseConfig.matchesSeller(seller, product.sellerName);
      final formOk = ProductFormFilter.matches(
        selectedForm: formLabel,
        productFormLabel: product.productFormLabel,
      );
      return categoryOk && sellerOk && formOk;
    }).toList();
  }
}
