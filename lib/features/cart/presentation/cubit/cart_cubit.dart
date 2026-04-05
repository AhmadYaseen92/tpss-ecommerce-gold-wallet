import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/add_cart_product_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/calculate_cart_summary_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/filter_cart_items_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/get_available_sellers_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/remove_cart_product_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/update_cart_product_quantity_usecase.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({
    required GetCartItemsUseCase getCartItemsUseCase,
    required AddCartProductUseCase addCartProductUseCase,
    required RemoveCartProductUseCase removeCartProductUseCase,
    required UpdateCartProductQuantityUseCase updateCartProductQuantityUseCase,
    CalculateCartSummaryUseCase calculateCartSummaryUseCase = const CalculateCartSummaryUseCase(),
    FilterCartItemsUseCase filterCartItemsUseCase = const FilterCartItemsUseCase(),
    GetAvailableSellersUseCase getAvailableSellersUseCase = const GetAvailableSellersUseCase(),
  }) : _getCartItemsUseCase = getCartItemsUseCase,
       _addCartProductUseCase = addCartProductUseCase,
       _removeCartProductUseCase = removeCartProductUseCase,
       _updateCartProductQuantityUseCase = updateCartProductQuantityUseCase,
       _calculateCartSummaryUseCase = calculateCartSummaryUseCase,
       _filterCartItemsUseCase = filterCartItemsUseCase,
       _getAvailableSellersUseCase = getAvailableSellersUseCase,
       super(CartInitial());

  final GetCartItemsUseCase _getCartItemsUseCase;
  final AddCartProductUseCase _addCartProductUseCase;
  final RemoveCartProductUseCase _removeCartProductUseCase;
  final UpdateCartProductQuantityUseCase _updateCartProductQuantityUseCase;
  final CalculateCartSummaryUseCase _calculateCartSummaryUseCase;
  final FilterCartItemsUseCase _filterCartItemsUseCase;
  final GetAvailableSellersUseCase _getAvailableSellersUseCase;

  String _sellerFilter = AppReleaseConfig.defaultSeller;
  List<CartItemEntity> _allItems = [];

  Future<void> loadCartProducts({String sellerFilter = AppReleaseConfig.allSellersLabel}) async {
    emit(CartLoading());
    try {
      _allItems = await _getCartItemsUseCase();
      final sellers = _getAvailableSellersUseCase(_allItems);

      if (AppReleaseConfig.isIndividualSellerRelease) {
        _sellerFilter = AppReleaseConfig.individualSellerName;
      } else if (sellerFilter == AppReleaseConfig.allSellersLabel && sellers.isNotEmpty) {
        _sellerFilter = sellers.first;
      } else {
        _sellerFilter = sellerFilter;
      }

      _emitLoaded();
    } catch (e) {
      emit(CartError('Failed to load cart products: $e'));
    }
  }

  Future<void> addProduct(CartItemEntity product) async {
    await _addCartProductUseCase(product);
    _allItems = await _getCartItemsUseCase();
    _emitLoaded();
  }

  Future<void> removeProduct(String id) async {
    await _removeCartProductUseCase(id);
    _allItems = await _getCartItemsUseCase();
    _emitLoaded();
  }

  Future<void> updateProductQuantity(String id, int quantity) async {
    await _updateCartProductQuantityUseCase(id, quantity);
    _allItems = await _getCartItemsUseCase();
    _emitLoaded();
  }

  void _emitLoaded() {
    final filtered = _filterCartItemsUseCase(items: _allItems, sellerFilter: _sellerFilter);
    final summary = _calculateCartSummaryUseCase(filtered);
    final sellers = _getAvailableSellersUseCase(_allItems);

    emit(
      CartLoaded(
        cartProducts: filtered,
        summary: summary,
        selectedSellerFilter: _sellerFilter,
        availableSellers: sellers,
      ),
    );
  }
}
