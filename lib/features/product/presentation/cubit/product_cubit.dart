import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/market_symbol_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/product_item_model.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  List<ProductItemModel> allProducts = [];
  List<MarketSymbolModel> marketSymbols = initialMarketSymbols;
  List<ProductItemModel> visibleCatalogProducts = [];
  List<MarketSymbolModel> visibleMarketSymbols = [];
  String selectedCategory = 'All';
  String activeSeller = AppReleaseConfig.defaultSeller;
  int quantity = 1;
  Timer? _marketTimer;

  ProductCubit() : super(ProductInitial());

  void loadProducts({String seller = AppReleaseConfig.allSellersLabel}) async {
    emit(ProductLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      allProducts = dummyProducts;
      selectedCategory = 'All';
      activeSeller = AppReleaseConfig.isIndividualSellerRelease
          ? AppReleaseConfig.individualSellerName
          : seller;
      _emitCatalog();
      _emitMarketWatch();
      _startMarketFeed();
    } catch (e) {
      emit(ProductError('Failed to load products: $e'));
    }
  }

  void onGlobalSellerChanged(String seller) {
    activeSeller = seller;
    _emitCatalog();
    _emitMarketWatch();
  }

  void applyCategoryFilter({required String category}) {
    selectedCategory = category;
    _emitCatalog();
  }

  void _emitCatalog() {
    visibleCatalogProducts = allProducts.where((product) {
      final categoryOk =
          selectedCategory == 'All' || product.category == selectedCategory;
      final sellerOk = AppReleaseConfig.matchesSeller(
        activeSeller,
        product.sellerName,
      );
      return categoryOk && sellerOk;
    }).toList();

    emit(
      ProductLoaded(
        products: visibleCatalogProducts,
        category: selectedCategory,
        seller: activeSeller,
      ),
    );
  }

  void toggleFavorite(String productId) {
    final index = allProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      allProducts[index] = allProducts[index].copyWith(
        isFavorite: !allProducts[index].isFavorite,
      );
      _emitCatalog();
    }
  }

  void loadProductDetail(String productId) async {
    emit(ProductDetailLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      final product = dummyProducts.firstWhere((p) => p.id == productId);
      allProducts = [product];
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductDetailError('Failed to load product detail: $e'));
    }
  }

  void toggleDetailFavorite(String productId) {
    final index = allProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final updatedProduct = allProducts[index].copyWith(
        isFavorite: !allProducts[index].isFavorite,
      );
      allProducts[index] = updatedProduct;
      emit(ProductDetailLoaded(updatedProduct));
    }
  }

  void _emitMarketWatch() {
    visibleMarketSymbols = marketSymbols.where((symbol) {
      return AppReleaseConfig.matchesSeller(activeSeller, symbol.sellerName);
    }).toList();
    emit(
      ProductMarketWatchLoaded(
        symbols: visibleMarketSymbols,
        seller: activeSeller,
      ),
    );
  }

  void _startMarketFeed() {
    _marketTimer?.cancel();
    final random = Random();
    _marketTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      marketSymbols = marketSymbols.map((symbol) {
        final move = (random.nextDouble() - 0.5) * 0.01;
        final newPrice = symbol.price * (1 + move);
        final newChange = symbol.change + (move * 100);
        return symbol.copyWith(price: newPrice, change: newChange);
      }).toList();
      _emitMarketWatch();
    });
  }

  int increaseQuantity() {
    quantity++;
    emit(ProductQuantityChanged(quantity));
    return quantity;
  }

  int decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
      emit(ProductQuantityChanged(quantity));
    }
    return quantity;
  }

  void addCart(ProductItemModel product) {
    final qtyToAdd = quantity;
    final idx = dummycartProducts.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      final existing = dummycartProducts[idx];
      dummycartProducts[idx] = existing.copyWith(
        quantity: existing.quantity + qtyToAdd,
      );
    } else {
      dummycartProducts.add(
        product.copyWith(quantity: qtyToAdd, isInCart: true),
      );
    }
  }

  @override
  Future<void> close() {
    _marketTimer?.cancel();
    return super.close();
  }
}
