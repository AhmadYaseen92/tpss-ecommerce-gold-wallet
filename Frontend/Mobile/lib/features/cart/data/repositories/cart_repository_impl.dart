import 'package:tpss_ecommerce_gold_wallet/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/repositories/cart_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/product_item_model.dart';

class CartRepositoryImpl implements ICartRepository {
  CartRepositoryImpl(this._localDataSource);

  final CartLocalDataSource _localDataSource;

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    final items = _localDataSource.getCartItems();
    return items.map(_toEntity).toList();
  }

  @override
  Future<void> addProduct(CartItemEntity item) async {
    _localDataSource.addProduct(_toModel(item));
  }

  @override
  Future<void> removeProduct(String id) async {
    _localDataSource.removeProduct(id);
  }

  @override
  Future<void> updateProductQuantity(String id, int quantity) async {
    _localDataSource.updateProductQuantity(id, quantity);
  }

  CartItemEntity _toEntity(ProductItemModel model) {
    return CartItemEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      price: model.price,
      imageUrl: model.imageUrl,
      sellerName: model.sellerName,
      quantity: model.quantity,
    );
  }

  ProductItemModel _toModel(CartItemEntity entity) {
    return ProductItemModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      imageUrl: entity.imageUrl,
      category: 'Bullion',
      sellerName: entity.sellerName,
      quantity: entity.quantity,
      isInCart: true,
    );
  }
}
