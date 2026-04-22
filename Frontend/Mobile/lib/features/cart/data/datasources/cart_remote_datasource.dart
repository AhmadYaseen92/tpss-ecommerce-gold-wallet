import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';

class CartRemoteDataSource {
  CartRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<CartRemoteItemModel>> getCartItems() async {
    final userId = _requireUserId();
    try {
      final response = await _dio.post('/cart/by-user', data: {'userId': userId});
      return _parseItems(response.data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      if (statusCode == 400 || statusCode == 404) {
        return const <CartRemoteItemModel>[];
      }
      rethrow;
    }
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

  Future<CartPreviewRemoteModel> previewCheckout({required List<int> productIds}) async {
    final userId = _requireUserId();
    final response = await _dio.post(
      '/wallet/actions/preview',
      data: {
        'userId': userId,
        'actionType': 'buy',
        'fromCart': true,
        'productIds': productIds,
      },
    );

    final data = ((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {});
    final feeBreakdowns = (data['feeBreakdowns'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(
          (line) => CartPreviewFeeBreakdownModel(
            feeName: (line['feeName'] ?? '').toString(),
            appliedValue: (line['appliedValue'] as num?)?.toDouble() ?? 0,
            isDiscount: (line['isDiscount'] as bool?) ?? false,
          ),
        )
        .toList();

    return CartPreviewRemoteModel(
      subTotalAmount: (data['subTotalAmount'] as num?)?.toDouble() ?? 0,
      totalFeesAmount: (data['totalFeesAmount'] as num?)?.toDouble() ?? 0,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0,
      finalAmount: (data['finalAmount'] as num?)?.toDouble() ?? 0,
      currency: (data['currency'] ?? 'USD').toString(),
      feeBreakdowns: feeBreakdowns,
    );
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
    required this.sellerId,
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
  final int sellerId;
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
      sellerId: (json['sellerId'] as num?)?.toInt() ?? 0,
      sellerName: (json['sellerName'] ?? '') as String,
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      weightValue: (json['weightValue'] as num?)?.toDouble() ?? 0,
      weightUnit: (json['weightUnit'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}

class CartPreviewRemoteModel {
  CartPreviewRemoteModel({
    required this.subTotalAmount,
    required this.totalFeesAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.currency,
    required this.feeBreakdowns,
  });

  final double subTotalAmount;
  final double totalFeesAmount;
  final double discountAmount;
  final double finalAmount;
  final String currency;
  final List<CartPreviewFeeBreakdownModel> feeBreakdowns;
}

class CartPreviewFeeBreakdownModel {
  CartPreviewFeeBreakdownModel({
    required this.feeName,
    required this.appliedValue,
    required this.isDiscount,
  });

  final String feeName;
  final double appliedValue;
  final bool isDiscount;
}
