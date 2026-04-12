import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/market_symbol_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/usecases/add_product_to_cart_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/usecases/filter_market_symbols_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/usecases/filter_products_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/usecases/get_product_detail_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/usecases/get_products_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/usecases/toggle_product_favorite_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/usecases/watch_market_symbols_usecase.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit({
    required GetProductsUseCase getProductsUseCase,
    required GetProductDetailUseCase getProductDetailUseCase,
    required ToggleProductFavoriteUseCase toggleProductFavoriteUseCase,
    required AddProductToCartUseCase addProductToCartUseCase,
    required WatchMarketSymbolsUseCase watchMarketSymbolsUseCase,
    FilterProductsUseCase filterProductsUseCase = const FilterProductsUseCase(),
    FilterMarketSymbolsUseCase filterMarketSymbolsUseCase = const FilterMarketSymbolsUseCase(),
  }) : _getProductsUseCase = getProductsUseCase,
       _getProductDetailUseCase = getProductDetailUseCase,
       _toggleProductFavoriteUseCase = toggleProductFavoriteUseCase,
       _addProductToCartUseCase = addProductToCartUseCase,
       _watchMarketSymbolsUseCase = watchMarketSymbolsUseCase,
       _filterProductsUseCase = filterProductsUseCase,
       _filterMarketSymbolsUseCase = filterMarketSymbolsUseCase,
       super(ProductInitial());

  final GetProductsUseCase _getProductsUseCase;
  final GetProductDetailUseCase _getProductDetailUseCase;
  final ToggleProductFavoriteUseCase _toggleProductFavoriteUseCase;
  final AddProductToCartUseCase _addProductToCartUseCase;
  final WatchMarketSymbolsUseCase _watchMarketSymbolsUseCase;
  final FilterProductsUseCase _filterProductsUseCase;
  final FilterMarketSymbolsUseCase _filterMarketSymbolsUseCase;

  List<ProductEntity> allProducts = [];
  List<MarketSymbolEntity> marketSymbols = [];
  List<ProductEntity> visibleCatalogProducts = [];
  List<MarketSymbolEntity> visibleMarketSymbols = [];

  int? selectedCategoryId;
  String activeSeller = AppReleaseConfig.defaultSeller;
  int quantity = 1;

  StreamSubscription<List<MarketSymbolEntity>>? _marketSubscription;

  Future<void> loadProducts({String seller = AppReleaseConfig.allSellersLabel}) async {
    emit(ProductLoading());
    try {
      allProducts = await _getProductsUseCase();
      selectedCategoryId = null;
      activeSeller = AppReleaseConfig.isIndividualSellerRelease
          ? AppReleaseConfig.individualSellerName
          : seller;

      _emitCatalog();
      await _startMarketWatch();
    } catch (e) {
      emit(ProductError('Failed to load products: $e'));
    }
  }

  void onGlobalSellerChanged(String seller) {
    activeSeller = seller;
    _emitCatalog();
    _emitMarketWatch();
  }

  void applyCategoryFilter({required int? categoryId}) {
    selectedCategoryId = categoryId;
    _emitCatalog();
  }

  Future<void> toggleFavorite(String productId) async {
    await _toggleProductFavoriteUseCase(productId);
    allProducts = await _getProductsUseCase();
    _emitCatalog();
  }

  Future<void> loadProductDetail(String productId) async {
    emit(ProductDetailLoading());
    try {
      final product = await _getProductDetailUseCase(productId);
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductDetailError('Failed to load product detail: $e'));
    }
  }

  Future<void> toggleDetailFavorite(String productId) async {
    await _toggleProductFavoriteUseCase(productId);
    final product = await _getProductDetailUseCase(productId);
    emit(ProductDetailLoaded(product));
  }

  Future<void> addCart(ProductEntity product) async {
    await _addProductToCartUseCase(product, quantity);
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

  Future<void> _startMarketWatch() async {
    await _marketSubscription?.cancel();
    _marketSubscription = _watchMarketSymbolsUseCase().listen((symbols) {
      marketSymbols = symbols;
      _emitMarketWatch();
    });
  }

  void _emitCatalog() {
    visibleCatalogProducts = _filterProductsUseCase(
      products: allProducts,
      categoryId: selectedCategoryId,
      seller: activeSeller,
    );

    emit(
      ProductLoaded(
        products: visibleCatalogProducts,
        categoryId: selectedCategoryId,
        seller: activeSeller,
      ),
    );
  }

  void _emitMarketWatch() {
    visibleMarketSymbols = _filterMarketSymbolsUseCase(
      symbols: marketSymbols,
      seller: activeSeller,
    );
    emit(
      ProductMarketWatchLoaded(
        symbols: visibleMarketSymbols,
        seller: activeSeller,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _marketSubscription?.cancel();
    return super.close();
  }
}
