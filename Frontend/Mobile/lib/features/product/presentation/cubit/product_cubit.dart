import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
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
  StreamSubscription<String>? _realtimeSubscription;
  bool _marketWatchRunning = false;
  String? _activeDetailProductId;
  ProductEntity? _currentDetailProduct;

  ProductEntity? get currentDetailProduct => _currentDetailProduct;

  Future<void> loadProducts({
    String seller = AppReleaseConfig.defaultAllSellersLabel,
    int? categoryId,
  }) async {
    emit(ProductLoading());
    try {
      selectedCategoryId = categoryId;
      allProducts = await _getProductsUseCase(categoryId: selectedCategoryId);
      activeSeller = AppReleaseConfig.isIndividualSellerRelease
          ? AppReleaseConfig.individualSellerName
          : seller;

      _emitCatalog();
      await syncMarketWatchWithConfig();
      await _startProductAutoRefresh();
    } catch (e) {
      emit(ProductError('Failed to load products: $e'));
    }
  }

  void onGlobalSellerChanged(String seller) {
    unawaited(
      loadProducts(
        seller: seller,
        categoryId: selectedCategoryId,
      ),
    );
  }

  void applyCategoryFilter({required int? categoryId}) {
    unawaited(
      loadProducts(
        seller: activeSeller,
        categoryId: categoryId,
      ),
    );
  }

  Future<void> toggleFavorite(String productId) async {
    await _toggleProductFavoriteUseCase(productId);
    allProducts = await _getProductsUseCase(categoryId: selectedCategoryId);
    _emitCatalog();
  }

  Future<void> loadProductDetail(String productId) async {
    emit(ProductDetailLoading());
    try {
      _activeDetailProductId = productId;
      await _startProductAutoRefresh();
      final product = await _getProductDetailUseCase(productId);
      _currentDetailProduct = product;
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductDetailError('Failed to load product detail: $e'));
    }
  }

  Future<void> toggleDetailFavorite(String productId) async {
    await _toggleProductFavoriteUseCase(productId);
    final product = await _getProductDetailUseCase(productId);
    _currentDetailProduct = product;
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


  Future<void> _silentRefreshProducts() async {
    try {
      allProducts = await _getProductsUseCase(categoryId: selectedCategoryId);
      _emitCatalog();
      if (_activeDetailProductId != null) {
        final product = await _getProductDetailUseCase(_activeDetailProductId!);
        _currentDetailProduct = product;
        emit(ProductDetailLoaded(product));
      }
    } catch (_) {
      // Keep last rendered catalog on background refresh failures.
    }
  }

  Future<void> _startProductAutoRefresh() async {
    await InjectionContainer.realtimeRefreshService().ensureStarted();
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = InjectionContainer.realtimeRefreshService().refreshes.listen((_) {
      unawaited(_silentRefreshProducts());
    });
  }

  Future<void> _startMarketWatch() async {
    await _marketSubscription?.cancel();
    _marketWatchRunning = true;
    _marketSubscription = _watchMarketSymbolsUseCase().listen((symbols) {
      marketSymbols = symbols;
      _emitMarketWatch();
    });
  }

  Future<void> syncMarketWatchWithConfig() async {
    if (AppReleaseConfig.marketWatchEnabled && !_marketWatchRunning) {
      await _startMarketWatch();
      return;
    }
    if (!AppReleaseConfig.marketWatchEnabled && _marketWatchRunning) {
      await _marketSubscription?.cancel();
      _marketSubscription = null;
      _marketWatchRunning = false;
      marketSymbols = [];
      visibleMarketSymbols = [];
      if (state is ProductMarketWatchLoaded) {
        _emitCatalog();
      }
    }
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
    await _realtimeSubscription?.cancel();
    await _marketSubscription?.cancel();
    _marketWatchRunning = false;
    return super.close();
  }
}
