import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  List<ProductItemModel> allProducts = [];
  String selectedCategory = 'All';
  String selectedSeller = 'All Sellers';
  int quantity = 1;

  ProductCubit() : super(ProductInitial());

  void loadProducts() async {
    emit(ProductLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      allProducts = dummyProducts;
      selectedCategory = 'All';
      selectedSeller = 'All Sellers';
      emit(
        ProductLoaded(
          products: allProducts,
          category: selectedCategory,
          seller: selectedSeller,
        ),
      );
    } catch (e) {
      emit(ProductError('Failed to load products: $e'));
    }
  }

  void applyFilters({String? category, String? seller}) {
    selectedCategory = category ?? selectedCategory;
    selectedSeller = seller ?? selectedSeller;

    var filtered = allProducts.where((product) {
      final categoryOk = selectedCategory == 'All' || product.category == selectedCategory;
      final sellerOk = selectedSeller == 'All Sellers' || product.sellerName == selectedSeller;
      return categoryOk && sellerOk;
    }).toList();

    emit(ProductLoaded(products: filtered, category: selectedCategory, seller: selectedSeller));
  }

  void toggleFavorite(String productId) {
    final index = allProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      allProducts[index] = allProducts[index].copyWith(
        isFavorite: !allProducts[index].isFavorite,
      );
      applyFilters();
    }
  }

  void loadProductDetail(String productId) async {
    emit(ProductDetailLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
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
      dummycartProducts.add(product.copyWith(quantity: qtyToAdd, isInCart: true));
    }
  }
}
