import 'package:tpss_ecommerce_gold_wallet/features/product/domain/repositories/product_repository.dart';

class ToggleProductFavoriteUseCase {
  const ToggleProductFavoriteUseCase(this._repository);

  final ProductRepository _repository;

  Future<void> call(String productId) => _repository.toggleFavorite(productId);
}
