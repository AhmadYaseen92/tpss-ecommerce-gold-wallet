import 'package:tpss_ecommerce_gold_wallet/features/product/data/datasources/product_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/market_symbol_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/market_symbol_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements IProductRepository {
  ProductRepositoryImpl(this._localDataSource);

  final ProductLocalDataSource _localDataSource;

  @override
  Future<List<ProductEntity>> getProducts() async {
    final products = await _localDataSource.getProducts();
    return products.map(_toEntity).toList();
  }

  @override
  Future<ProductEntity> getProductDetail(String productId) async {
    final product = await _localDataSource.getProductDetail(productId);
    return _toEntity(product);
  }

  @override
  Future<void> toggleFavorite(String productId) {
    return _localDataSource.toggleFavorite(productId);
  }

  @override
  Future<void> addToCart(ProductEntity product, int quantity) {
    return _localDataSource.addToCart(_toModel(product), quantity);
  }

  @override
  Stream<List<MarketSymbolEntity>> watchMarketSymbols() {
    return _localDataSource.watchMarketSymbols().map(
      (items) => items.map(_toSymbolEntity).toList(),
    );
  }

  ProductEntity _toEntity(ProductItemModel model) {
    return ProductEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      price: model.price,
      imageUrl: model.imageUrl,
      category: model.category,
      isFavorite: model.isFavorite,
      purity: model.purity,
      weight: model.weight,
      metal: model.metal,
      isInCart: model.isInCart,
      quantity: model.quantity,
      sellerName: model.sellerName,
    );
  }

  ProductItemModel _toModel(ProductEntity entity) {
    return ProductItemModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      imageUrl: entity.imageUrl,
      category: entity.category,
      isFavorite: entity.isFavorite,
      purity: entity.purity,
      weight: entity.weight,
      metal: entity.metal,
      isInCart: entity.isInCart,
      quantity: entity.quantity,
      sellerName: entity.sellerName,
    );
  }

  MarketSymbolEntity _toSymbolEntity(MarketSymbolModel model) {
    return MarketSymbolEntity(
      symbol: model.symbol,
      name: model.name,
      price: model.price,
      change: model.change,
      sellerName: model.sellerName,
    );
  }
}
