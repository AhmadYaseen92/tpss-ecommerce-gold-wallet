import 'dart:async';
import 'dart:math';

import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/market_symbol_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/product_item_model.dart';

class ProductLocalDataSource {
  final List<ProductItemModel> _products = List<ProductItemModel>.from(dummyProducts);
  List<MarketSymbolModel> _symbols = List<MarketSymbolModel>.from(initialMarketSymbols);

  final StreamController<List<MarketSymbolModel>> _symbolController =
      StreamController<List<MarketSymbolModel>>.broadcast();
  Timer? _marketTimer;

  Future<List<ProductItemModel>> getProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<ProductItemModel>.from(_products);
  }

  Future<ProductItemModel> getProductDetail(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _products.firstWhere((p) => p.id == productId);
  }

  Future<void> toggleFavorite(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;
    _products[index] = _products[index].copyWith(isFavorite: !_products[index].isFavorite);
  }

  Future<void> addToCart(ProductItemModel product, int quantity) async {
    final idx = dummycartProducts.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      final existing = dummycartProducts[idx];
      dummycartProducts[idx] = existing.copyWith(quantity: existing.quantity + quantity);
      return;
    }
    dummycartProducts.add(product.copyWith(quantity: quantity, isInCart: true));
  }

  Stream<List<MarketSymbolModel>> watchMarketSymbols() {
    _startFeedIfNeeded();
    _symbolController.add(List<MarketSymbolModel>.from(_symbols));
    return _symbolController.stream;
  }

  void dispose() {
    _marketTimer?.cancel();
    _symbolController.close();
  }

  void _startFeedIfNeeded() {
    if (_marketTimer != null) return;
    final random = Random();
    _marketTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _symbols = _symbols.map((symbol) {
        final move = (random.nextDouble() - 0.5) * 0.01;
        final newPrice = symbol.price * (1 + move);
        final newChange = symbol.change + (move * 100);
        return symbol.copyWith(price: newPrice, change: newChange);
      }).toList();
      _symbolController.add(List<MarketSymbolModel>.from(_symbols));
    });
  }
}
