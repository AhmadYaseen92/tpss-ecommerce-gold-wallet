import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/repositories/product_repository.dart';

class AddProductToCartUseCase {
  const AddProductToCartUseCase(this._repository);

  final IProductRepository _repository;

  Future<void> call(ProductEntity product, int quantity) => _repository.addToCart(product, quantity);
}
