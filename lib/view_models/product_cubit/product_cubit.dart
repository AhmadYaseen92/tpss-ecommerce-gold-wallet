import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  List<ProductItemModel> allProducts = []; // Keep reference to all products
  String selectedCategory = 'All';

  ProductCubit() : super(ProductInitial());

  void loadProducts() async {
    emit(ProductLoading());
    try {
      // Simulate a delay for loading products
      await Future.delayed(const Duration(milliseconds: 1000));
      // Load dummy products (replace with actual data fetching logic)
      allProducts = dummyProducts; // Store all products
      selectedCategory = 'All';
      emit(ProductLoaded(allProducts));
    } catch (e) {
      emit(ProductError('Failed to load products: $e'));
    }
  }

  void filterProducts(String category) {
    selectedCategory = category;
    final filteredProducts = allProducts
        .where((product) => product.category == category)
        .toList();
    emit(ProductFiltered(filteredProducts: filteredProducts,category: category));
  }

  void toggleFavorite(String productId) {
    final index = allProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final updatedProduct = allProducts[index].copyWith(
        isFavorite: !allProducts[index].isFavorite,
      );
      allProducts[index] = updatedProduct;

      // Re-apply the active filter so the view doesn't reset to all products
      if (selectedCategory == 'All') {
        emit(ProductLoaded(allProducts));
      } else {
        final filtered = allProducts
             .where((p) => p.category == selectedCategory)
           .toList();
       emit(ProductFiltered(filteredProducts: filtered,category: selectedCategory));
      }
    }
  }
}
