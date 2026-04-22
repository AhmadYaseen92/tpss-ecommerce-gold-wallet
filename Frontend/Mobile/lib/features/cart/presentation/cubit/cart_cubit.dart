import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/product_category_filter.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/add_cart_product_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/filter_cart_items_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/get_available_sellers_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/remove_cart_product_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/update_cart_product_quantity_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/repositories/cart_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({
    required GetCartItemsUseCase getCartItemsUseCase,
    required AddCartProductUseCase addCartProductUseCase,
    required RemoveCartProductUseCase removeCartProductUseCase,
    required UpdateCartProductQuantityUseCase updateCartProductQuantityUseCase,
    required ICartRepository cartRepository,
    FilterCartItemsUseCase filterCartItemsUseCase = const FilterCartItemsUseCase(),
    GetAvailableSellersUseCase getAvailableSellersUseCase = const GetAvailableSellersUseCase(),
  }) : _getCartItemsUseCase = getCartItemsUseCase,
       _addCartProductUseCase = addCartProductUseCase,
       _removeCartProductUseCase = removeCartProductUseCase,
       _updateCartProductQuantityUseCase = updateCartProductQuantityUseCase,
       _cartRepository = cartRepository,
       _filterCartItemsUseCase = filterCartItemsUseCase,
       _getAvailableSellersUseCase = getAvailableSellersUseCase,
       super(CartInitial());

  final GetCartItemsUseCase _getCartItemsUseCase;
  final AddCartProductUseCase _addCartProductUseCase;
  final RemoveCartProductUseCase _removeCartProductUseCase;
  final UpdateCartProductQuantityUseCase _updateCartProductQuantityUseCase;
  final ICartRepository _cartRepository;
  final FilterCartItemsUseCase _filterCartItemsUseCase;
  final GetAvailableSellersUseCase _getAvailableSellersUseCase;

  String _sellerFilter = AppReleaseConfig.defaultSeller;
  int? _categoryFilter;
  List<CartItemEntity> _allItems = [];
  StreamSubscription<String>? _realtimeSubscription;
  DateTime? _lastAutoRefreshAt;

  Future<void> loadCartProducts({String sellerFilter = AppReleaseConfig.defaultAllSellersLabel}) async {
    _safeEmit(CartLoading());
    try {
      _allItems = await _getCartItemsUseCase();
      final sellers = _getAvailableSellersUseCase(_allItems);
      _sellerFilter = _resolveSellerFilter(
        sellers: sellers,
        requestedSellerFilter: sellerFilter,
      );

      await _emitLoaded();
      await _startAutoRefresh();
    } catch (e) {
      _safeEmit(CartError('Failed to load cart products: $e'));
    }
  }

  Future<void> addProduct(CartItemEntity product) async {
    await _addCartProductUseCase(product);
    _allItems = await _getCartItemsUseCase();
    await _emitLoaded();
  }

  Future<void> removeProduct(String id) async {
    await _removeCartProductUseCase(id);
    _allItems = await _getCartItemsUseCase();
    await _emitLoaded();
  }

  Future<void> updateProductQuantity(String id, int quantity) async {
    await _updateCartProductQuantityUseCase(id, quantity);
    _allItems = await _getCartItemsUseCase();
    await _emitLoaded();
  }

  void setCategoryFilter(int? categoryId) {
    _categoryFilter = categoryId;
    unawaited(_emitLoaded());
  }

  Future<void> _emitLoaded() async {
    var filtered = _filterCartItemsUseCase(items: _allItems, sellerFilter: _sellerFilter);
    if (_categoryFilter != null) {
      filtered = filtered.where((item) {
        final id = ProductCategoryFilter.inferCategoryId(
          name: item.name,
          description: item.description,
        );
        return id == _categoryFilter;
      }).toList();
    }
    final sellers = _getAvailableSellersUseCase(_allItems);

    if (filtered.isEmpty && sellers.isNotEmpty) {
      _sellerFilter = sellers.first;
      filtered = _filterCartItemsUseCase(items: _allItems, sellerFilter: _sellerFilter);
    }

    final summary = filtered.isEmpty
        ? const CartSummaryEntity(
            subtotal: 0,
            totalFeesAmount: 0,
            discountAmount: 0,
            total: 0,
            currency: 'USD',
            feeBreakdowns: [],
          )
        : await _cartRepository.previewSummary(filtered.map((item) => item.id).toList());

    _safeEmit(
      CartLoaded(
        cartProducts: filtered,
        summary: summary,
        selectedSellerFilter: _sellerFilter,
        availableSellers: sellers,
        selectedCategoryId: _categoryFilter,
      ),
    );
  }

  String _resolveSellerFilter({
    required List<String> sellers,
    required String requestedSellerFilter,
  }) {
    if (AppReleaseConfig.isIndividualSellerRelease) {
      return AppReleaseConfig.individualSellerName;
    }
    if (sellers.contains(requestedSellerFilter)) {
      return requestedSellerFilter;
    }
    if (sellers.contains(_sellerFilter)) {
      return _sellerFilter;
    }
    if (sellers.isNotEmpty) {
      return sellers.first;
    }
    return requestedSellerFilter;
  }

  Future<void> _startAutoRefresh() async {
    await InjectionContainer.realtimeRefreshService().ensureStarted();
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = InjectionContainer.realtimeRefreshService().refreshes.listen((_) {
      unawaited(_silentRefreshCartProducts());
    });
  }

  Future<void> _silentRefreshCartProducts() async {
    final now = DateTime.now();
    final last = _lastAutoRefreshAt;
    if (last != null && now.difference(last) < const Duration(seconds: 4)) {
      return;
    }
    _lastAutoRefreshAt = now;

    try {
      _allItems = await _getCartItemsUseCase();
      await _emitLoaded();
    } catch (_) {
      // Keep previous cart view on transient refresh failures.
    }
  }

  @override
  Future<void> close() async {
    await _realtimeSubscription?.cancel();
    return super.close();
  }

  void _safeEmit(CartState state) {
    if (isClosed) return;
    emit(state);
  }
}
