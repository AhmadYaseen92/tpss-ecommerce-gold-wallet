import 'dart:collection';

import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/datasources/product_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/datasources/product_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/market_symbol_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/market_symbol_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements IProductRepository {
  ProductRepositoryImpl(this._remoteDataSource, this._localDataSource, this._cartRemoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;
  final CartRemoteDataSource _cartRemoteDataSource;
  final Set<String> _favoriteProductIds = HashSet<String>();

  @override
  Future<List<ProductEntity>> getProducts() async {
    final products = await _remoteDataSource.getProducts(pageNumber: 1, pageSize: 20);
    return products.map(_toEntity).toList();
  }

  @override
  Future<ProductEntity> getProductDetail(String productId) async {
    final allProducts = await getProducts();
    return allProducts.firstWhere((product) => product.id == productId);
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
      return;
    }
    _favoriteProductIds.add(productId);
  }

  @override
  Future<void> addToCart(ProductEntity product, int quantity) async {
    final userSellerId = AuthSessionStore.sellerId;
    if (userSellerId != null && product.sellerId != userSellerId) {
      throw Exception('Product does not belong to your seller scope.');
    }

    final productId = int.tryParse(product.id);
    if (productId == null) {
      throw Exception('Invalid product id for server add-to-cart.');
    }
    await _cartRemoteDataSource.addProduct(productId: productId, quantity: quantity);
  }

  @override
  Stream<List<MarketSymbolEntity>> watchMarketSymbols() {
    return _localDataSource.watchMarketSymbols().map(
      (items) => items.map(_toSymbolEntity).toList(),
    );
  }

  ProductEntity _toEntity(ProductRemoteModel model) {
    return ProductEntity(
      id: model.id.toString(),
      sellerId: model.sellerId,
      name: model.name,
      description: model.description,
      price: model.price,
      imageUrl: _imageBySkuOrName(sku: model.sku, name: model.name),
      category: _categoryByName(model.name),
      isFavorite: _favoriteProductIds.contains(model.id.toString()),
      purity: _purityByDescription(model.description),
      weight: _weightBySku(model.sku),
      metal: _metalByName(model.name),
      isInCart: false,
      quantity: 1,
      sellerName: model.sellerName,
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

  String _categoryByName(String name) {
    final value = name.toLowerCase();
    if (value.contains('ring') || value.contains('necklace') || value.contains('pendant') || value.contains('earring')) {
      return 'Jewellery';
    }
    if (value.contains('coin')) return 'Coins';
    return 'Bullion';
  }

  String _metalByName(String name) {
    final value = name.toLowerCase();
    if (value.contains('silver')) return 'Silver';
    if (value.contains('platinum')) return 'Platinum';
    if (value.contains('palladium')) return 'Palladium';
    return 'Gold';
  }

  String _purityByDescription(String description) {
    final normalized = description.toLowerCase();
    if (normalized.contains('24k')) return '24k';
    if (normalized.contains('22k')) return '22k';
    if (normalized.contains('18k')) return '18k';
    if (normalized.contains('999.9')) return '999.9';
    return '';
  }

  String _weightBySku(String sku) {
    final normalized = sku.toUpperCase();
    if (normalized.contains('1OZ')) return '1 oz';
    if (normalized.contains('10G')) return '10 g';
    if (normalized.contains('1KG')) return '1 kg';
    return '';
  }

  String _imageBySkuOrName({required String sku, required String name}) {
    const skuImages = {
      'XAU-1OZ': 'https://www.pamp.com/sites/pamp/files/2022-02/1oz_gold_sfondo_lucido_obv.png',
      'XAU-10G': 'https://www.pamp.com/sites/pamp/files/2022-02/10g_1.png',
      'XAG-1KG': 'https://www.pamp.com/sites/pamp/files/2024-10/pamp-1oz-silver-bar-usa-webimage-1000x1000px-obv.png',
    };

    final imageFromSku = skuImages[sku.toUpperCase()];
    if (imageFromSku != null) return imageFromSku;

    if (name.toLowerCase().contains('silver')) {
      return 'https://www.pamp.com/sites/pamp/files/2024-10/pamp-1oz-silver-bar-usa-webimage-1000x1000px-obv.png';
    }
    return 'https://www.pamp.com/sites/pamp/files/2022-02/10g_1.png';
  }
}
