import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/market_symbol_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';

abstract class IProductRepository {
  Future<List<ProductEntity>> getProducts({int? categoryId});

  Future<ProductEntity> getProductDetail(String productId);

  Future<void> toggleFavorite(String productId);

  Future<void> addToCart(ProductEntity product, int quantity);

  Stream<List<MarketSymbolEntity>> watchMarketSymbols();
}
