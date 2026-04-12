import 'package:tpss_ecommerce_gold_wallet/core/constants/api_config.dart';
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
    final normalizedImageUrl = _normalizeImageUrl(model.productImageUrl);

    return CartItemEntity(
      id: model.productId.toString(),
      name: model.productName,
      description: model.productDescription,
      price: model.unitPrice,
      imageUrl: normalizedImageUrl,
      sellerId: model.sellerId,
      sellerName: model.sellerName,
      availableStock: model.availableStock,
      weight: '${model.weightValue} ${model.weightUnit}',
      quantity: model.quantity,
    );
  }

  String _normalizeImageUrl(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.isEmpty) return '';

    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
      return trimmed;
    }

    final apiBase = Uri.tryParse(ApiConfig.baseUrl);
    if (apiBase == null) return trimmed;

    final origin = '${apiBase.scheme}://${apiBase.host}${apiBase.hasPort ? ':${apiBase.port}' : ''}';
    final normalizedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$origin$normalizedPath';
  }
}
