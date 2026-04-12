import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';

class CartRemoteDataSource {
  CartRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<CartRemoteItemModel>> getCartItems() async {
    final userId = _requireUserId();
    final response = await _dio.post('/cart/by-user', data: {'userId': userId});
    return _parseItems(response.data);
  }

  Future<void> addProduct({required int productId, required int quantity}) async {
    final userId = _requireUserId();
    await _dio.post('/cart/items', data: {'userId': userId, 'productId': productId, 'quantity': quantity});
  }

  Future<void> updateProductQuantity({required int productId, required int quantity}) async {
    final userId = _requireUserId();
    await _dio.put('/cart/items', data: {'userId': userId, 'productId': productId, 'quantity': quantity});
  }

  Future<void> removeProduct({required int productId}) async {
    final userId = _requireUserId();
    await _dio.delete('/cart/items/$userId/$productId');
  }

  int _requireUserId() {
    final id = AuthSessionStore.userId;
    if (id == null) {
      throw Exception('No logged-in user. Please login first.');
    }
    return id;
  }

  List<CartRemoteItemModel> _parseItems(dynamic payload) {
    final map = payload as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>?;
    final items = (data?['items'] as List<dynamic>? ?? []);
    return items
        .map((e) => CartRemoteItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class CartRemoteItemModel {
  CartRemoteItemModel({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productImageUrl,
    required this.sellerName,
    required this.availableStock,
    required this.unitPrice,
    required this.weightValue,
    required this.weightUnit,
    required this.quantity,
  });

  final int productId;
  final String productName;
  final String productDescription;
  final String productImageUrl;
  final String sellerName;
  final int availableStock;
  final double unitPrice;
  final double weightValue;
  final String weightUnit;
  final int quantity;

  factory CartRemoteItemModel.fromJson(Map<String, dynamic> json) {
    return CartRemoteItemModel(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productName: (json['productName'] ?? '') as String,
      productDescription: (json['productDescription'] ?? '') as String,
      productImageUrl: (json['productImageUrl'] ?? '') as String,
      sellerName: (json['sellerName'] ?? '') as String,
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      weightValue: (json['weightValue'] as num?)?.toDouble() ?? 0,
      weightUnit: (json['weightUnit'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}
