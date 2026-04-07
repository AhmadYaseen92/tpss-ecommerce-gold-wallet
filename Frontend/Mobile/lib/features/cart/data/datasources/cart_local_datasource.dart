import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/product_item_model.dart';

class CartLocalDataSource {
  List<ProductItemModel> getCartItems() {
    return List<ProductItemModel>.from(dummycartProducts);
  }

  void addProduct(ProductItemModel product) {
    final existingIndex = dummycartProducts.indexWhere((item) => item.id == product.id);

    if (existingIndex != -1) {
      final existing = dummycartProducts[existingIndex];
      dummycartProducts[existingIndex] = existing.copyWith(quantity: existing.quantity + product.quantity);
    } else {
      dummycartProducts.add(product);
    }
  }

  void removeProduct(String id) {
    dummycartProducts.removeWhere((item) => item.id == id);
  }

  void updateProductQuantity(String id, int quantity) {
    final safeQty = quantity < 1 ? 1 : quantity;
    final index = dummycartProducts.indexWhere((item) => item.id == id);
    if (index != -1) {
      dummycartProducts[index] = dummycartProducts[index].copyWith(quantity: safeQty);
    }
  }
}
