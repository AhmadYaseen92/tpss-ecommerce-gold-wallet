import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/product_item_model.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  String _sellerFilter = AppReleaseConfig.defaultSeller;

  void loadCartProducts({String sellerFilter = AppReleaseConfig.allSellersLabel}) async {
    if (AppReleaseConfig.isIndividualSellerRelease) {
      _sellerFilter = AppReleaseConfig.individualSellerName;
    } else {
      final sellers = availableSellers;
      if (sellerFilter == AppReleaseConfig.allSellersLabel && sellers.isNotEmpty) {
        _sellerFilter = sellers.first;
      } else {
        _sellerFilter = sellerFilter;
      }
    }
    emit(CartLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(CartLoaded(cartProducts: _filteredProducts));
    } catch (e) {
      emit(CartError('Failed to load cart products: $e'));
    }
  }

  List<ProductItemModel> get _filteredProducts {
    return dummycartProducts
        .where((p) => AppReleaseConfig.matchesSeller(_sellerFilter, p.sellerName))
        .toList();
  }

  String get selectedSellerFilter => _sellerFilter;

  List<String> get availableSellers {
    final sellers = dummycartProducts.map((p) => p.sellerName).toSet().toList()..sort();
    return sellers;
  }

  void addProduct(ProductItemModel product) {
    final existingIndex = dummycartProducts.indexWhere((item) => item.id == product.id);

    if (existingIndex != -1) {
      final existing = dummycartProducts[existingIndex];
      dummycartProducts[existingIndex] = existing.copyWith(
        quantity: existing.quantity + product.quantity,
      );
    } else {
      dummycartProducts.add(product);
    }
    emit(CartLoaded(cartProducts: _filteredProducts));
  }

  void removeProduct(String id) {
    dummycartProducts.removeWhere((item) => item.id == id);
    emit(CartLoaded(cartProducts: _filteredProducts));
  }

  void updateProductQuantity(String id, int quantity) {
    final safeQty = quantity < 1 ? 1 : quantity;
    final index = dummycartProducts.indexWhere((item) => item.id == id);
    if (index != -1) {
      dummycartProducts[index] = dummycartProducts[index].copyWith(quantity: safeQty);
      emit(CartLoaded(cartProducts: _filteredProducts));
    }
  }

  double get subtotal {
    if (state is! CartLoaded) return 0.0;
    return (state as CartLoaded).cartProducts.fold(0.0, (sum, product) {
      return sum + (product.price * product.quantity);
    });
  }

  double get tax => subtotal * 0.05;

  double get total => subtotal + tax;
}
