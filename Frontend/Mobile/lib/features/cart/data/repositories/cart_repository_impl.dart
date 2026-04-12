import 'package:tpss_ecommerce_gold_wallet/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements ICartRepository {
  CartRepositoryImpl(this._remoteDataSource);

  final CartRemoteDataSource _remoteDataSource;

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    final items = await _remoteDataSource.getCartItems();
    return items.map(_toEntity).toList();
  }

  @override
  Future<void> addProduct(CartItemEntity item) async {
    final productId = int.tryParse(item.id) ?? 0;
    if (productId <= 0) {
      throw Exception('Invalid product id for server cart add.');
    }
    await _remoteDataSource.addProduct(productId: productId, quantity: item.quantity);
  }

  @override
  Future<void> removeProduct(String id) async {
    final productId = int.tryParse(id) ?? 0;
    if (productId <= 0) {
      throw Exception('Invalid product id for server cart remove.');
    }
    await _remoteDataSource.removeProduct(productId: productId);
  }

  @override
  Future<void> updateProductQuantity(String id, int quantity) async {
    final productId = int.tryParse(id) ?? 0;
    if (productId <= 0) {
      throw Exception('Invalid product id for server cart update.');
    }
    await _remoteDataSource.updateProductQuantity(productId: productId, quantity: quantity);
  }

  CartItemEntity _toEntity(CartRemoteItemModel model) {
    return CartItemEntity(
      id: model.productId.toString(),
      name: model.productName,
      description: model.productDescription,
      price: model.unitPrice,
      imageUrl: model.productImageUrl.trim().isNotEmpty
          ? model.productImageUrl
          : _imageByName(model.productName),
      sellerName: model.sellerName,
      availableStock: model.availableStock,
      weight: '${model.weightValue} ${model.weightUnit}',
      quantity: model.quantity,
    );
  }

  String _imageByName(String name) {
    final value = name.toLowerCase();
    if (value.contains('silver')) {
      return 'https://www.pamp.com/sites/pamp/files/2024-10/pamp-1oz-silver-bar-usa-webimage-1000x1000px-obv.png';
    }
    return 'https://www.pamp.com/sites/pamp/files/2022-02/10g_1.png';
  }
}
