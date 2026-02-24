import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  List<ProductItemModel> allProducts = []; // Keep reference to all products

  ProductCubit() : super(ProductInitial());

  void loadProducts() async {
    emit(ProductLoading());
    try {
      // Simulate a delay for loading products
      await Future.delayed(const Duration(milliseconds: 1000));
      // Load dummy products (replace with actual data fetching logic)
      allProducts = dummyProducts; // Store all products
      emit(ProductLoaded(allProducts));
    } catch (e) {
      emit(ProductError('Failed to load products: $e'));
    }
  }

  void filterProducts(String category) {
    final filteredProducts = allProducts
        .where((product) => product.category == category)
        .toList();
    emit(ProductFiltered(filteredProducts));
  }
}
