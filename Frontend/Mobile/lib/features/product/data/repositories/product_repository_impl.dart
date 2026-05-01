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

    allModels.sort((a, b) => b.id.compareTo(a.id));
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
    final normalizedVideoUrl = _normalizeImageUrl(model.videoUrl);

    return ProductEntity(
      id: model.id.toString(),
      sellerId: model.sellerId,
      name: model.name,
      description: model.description,
      baseMarketPrice: model.baseMarketPrice,
      autoPrice: model.autoPrice,
      fixedPrice: model.fixedPrice,
      askPrice: model.askPrice,
      availableStock: model.availableStock,
      imageUrl: normalizedImageUrl,
      videoUrl: normalizedVideoUrl,
      category: _categoryLabelById(model.categoryId),
      categoryId: model.categoryId,
      isFavorite: _favoriteProductIds.contains(model.id.toString()),
      purity: _resolvePurity(model),
      weight: _weightText(model.weightValue, model.weightUnit),
      materialTypeLabel: _materialTypeLabel(model.materialType, model.categoryId),
      productFormLabel: _productFormLabel(model.formType, model.categoryId),
      isInCart: false,
      quantity: 1,
      sellerName: model.sellerName,
      offerType: model.offerType,
      offerPercent: model.offerPercent,
      offerNewPrice: model.offerNewPrice,
      isHasOffer: model.isHasOffer,
      pricingModeLabel: _pricingModeLabel(model.pricingMode),
      currencyCode: model.currencyCode,
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

  String _materialTypeLabel(String materialType, int categoryId) {
    final normalized = materialType.trim().toLowerCase();
    if (normalized == 'gold' || normalized == 'silver' || normalized == 'diamond') {
      return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
    }

    return switch (categoryId) {
      1 => 'Gold',
      2 => 'Silver',
      3 => 'Diamond',
      _ => 'Gold',
    };
  }



  String _productFormLabel(String formType, int categoryId) {
    final normalized = formType.trim().toLowerCase();
    if (normalized == '1' || normalized == 'jewelry') return 'Jewelry';
    if (normalized == '2' || normalized == 'coin') return 'Coin';
    if (normalized == '3' || normalized == 'bar') return 'Bar';
    if (normalized.isNotEmpty && normalized != 'other') {
      return normalized[0].toUpperCase() + normalized.substring(1);
    }

    return switch (categoryId) {
      3 => 'Jewelry',
      5 => 'Coin',
      4 => 'Jewelry',
      _ => 'Bar',
    };
  }

  String _pricingModeLabel(String pricingMode) {
    final normalized = pricingMode.trim().toLowerCase();
    if (normalized.contains('auto')) return 'Auto Price';
    return 'Manual Price';
  }

  String _purityByDescription(String description) {
    final normalized = description.toLowerCase();
    if (normalized.contains('24k')) return '24k';
    if (normalized.contains('22k')) return '22k';
    if (normalized.contains('18k')) return '18k';
    if (normalized.contains('999.9')) return '999.9';
    return '';
  }

  String _resolvePurity(ProductRemoteModel model) {
    final material = model.materialType.trim().toLowerCase();
    final isSilver = material == 'silver' || material == '2';
    final isDiamond = material == 'diamond' || material == '3';

    if (isDiamond) {
      return '';
    }

    if (isSilver) {
      if (model.purityFactor <= 0) return '';
      if ((model.purityFactor - 0.9999).abs() < 0.00001) return '9999';
      if ((model.purityFactor - 0.999).abs() < 0.00001) return '999';
      if ((model.purityFactor - 0.925).abs() < 0.00001) return '925';
      final scaled = model.purityFactor >= 0.99
          ? (model.purityFactor * 10000).round()
          : (model.purityFactor * 1000).round();
      return scaled.toString();
    }

    final karatValue = model.purityKarat.trim().toUpperCase();
    const validKarats = {'24K', '22K', '21K', '18K', '14K'};
    if (validKarats.contains(karatValue)) {
      return karatValue;
    }

    if (model.purityFactor > 0) {
      final mapped = (model.purityFactor * 24).round();
      if (validKarats.contains('${mapped}K')) {
        return '${mapped}K';
      }
    }

    return _purityByDescription(model.description).toUpperCase();
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
