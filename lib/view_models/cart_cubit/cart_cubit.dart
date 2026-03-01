import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  void loadCartProducts() async {
    emit(CartLoading());
    try {
      // Simulate a delay for loading cart products
      await Future.delayed(const Duration(milliseconds: 1000));
      // Load cart products (replace with actual data fetching logic)
      emit(
        CartLoaded(cartProducts: dummycartProducts),
      ); // Pass actual cart products here
    } catch (e) {
      emit(CartError('Failed to load cart products: $e'));
    }
  }

  void addProduct(ProductItemModel product) {
    final existingIndex = dummycartProducts.indexWhere(
      (item) => item.id == product.id,
    );

    if (existingIndex != -1) {
      final existing = dummycartProducts[existingIndex];
      dummycartProducts[existingIndex] = existing.copyWith(
        quantity: existing.quantity + product.quantity,
      );
    } else {
      dummycartProducts.add(product);
    }
    emit(CartLoaded(cartProducts: dummycartProducts));
  }

  void removeProduct(String id) {
    dummycartProducts.removeWhere((item) => item.id == id);
    emit(CartLoaded(cartProducts: dummycartProducts));
  }

  void updateProductQuantity(String id, int quantity) {
    final safeQty = quantity < 1 ? 1 : quantity;
    final index = dummycartProducts.indexWhere((item) => item.id == id);
    if (index != -1) {
      dummycartProducts[index] = dummycartProducts[index].copyWith(
        quantity: safeQty,
      );
      emit(CartLoaded(cartProducts: dummycartProducts));
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
