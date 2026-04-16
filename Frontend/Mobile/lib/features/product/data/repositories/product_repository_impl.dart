import 'dart:collection';

import 'package:tpss_ecommerce_gold_wallet/core/constants/api_config.dart';
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
  Future<List<ProductEntity>> getProducts({int? categoryId}) async {
    const pageSize = 50;
    final allModels = <ProductRemoteModel>[];
    var pageNumber = 1;
    var totalCount = 0;

    do {
      final response = await _remoteDataSource.getProducts(
        pageNumber: pageNumber,
        pageSize: pageSize,
        categoryId: categoryId,
      );
      allModels.addAll(response.items);
      totalCount = response.totalCount;
      pageNumber++;
    } while (allModels.length < totalCount && totalCount > 0);

    return allModels.map(_toEntity).toList();
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
    if (quantity > product.availableStock) {
      throw Exception(
        'Requested quantity $quantity exceeds available stock ${product.availableStock}.',
      );
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
    final normalizedImageUrl = _normalizeImageUrl(model.imageUrl);

    return ProductEntity(
      id: model.id.toString(),
      sellerId: model.sellerId,
      name: model.name,
      description: model.description,
      price: model.price,
      availableStock: model.availableStock,
      imageUrl: normalizedImageUrl,
      category: _categoryLabelById(model.categoryId),
      categoryId: model.categoryId,
      isFavorite: _favoriteProductIds.contains(model.id.toString()),
      purity: _purityByDescription(model.description),
      weight: _weightText(model.weightValue, model.weightUnit),
      metal: model.pricingMaterialType,
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

  String _categoryLabelById(int categoryId) {
    return switch (categoryId) {
      1 => 'Gold',
      2 => 'Silver',
      3 => 'Diamond',
      4 => 'Jewelry',
      5 => 'Coins',
      6 => 'Spot MR',
      _ => 'Gold',
    };
  }

  String _purityByDescription(String description) {
    final normalized = description.toLowerCase();
    if (normalized.contains('24k')) return '24k';
    if (normalized.contains('22k')) return '22k';
    if (normalized.contains('18k')) return '18k';
    if (normalized.contains('999.9')) return '999.9';
    return '';
  }

  String _weightText(double weightValue, String weightUnit) {
    if (weightValue <= 0) return '';

    final normalizedUnit = weightUnit.trim().toLowerCase();
    final suffix = switch (normalizedUnit) {
      'gram' => 'g',
      'kilogram' => 'kg',
      'ounce' => 'oz',
      _ => normalizedUnit,
    };
    final normalizedWeight = weightValue % 1 == 0
        ? weightValue.toStringAsFixed(0)
        : weightValue.toStringAsFixed(3);
    return '$normalizedWeight $suffix';
  }

  String _normalizeImageUrl(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.isEmpty) return '';

    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
      return trimmed;
    }

    final apiBase = Uri.tryParse(ApiConfig.baseUrl);
    if (apiBase == null) return trimmed;

    final origin = '${apiBase.scheme}://${apiBase.host}${apiBase.hasPort ? ':${apiBase.port}' : ''}';
    final normalizedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$origin$normalizedPath';
  }
}
