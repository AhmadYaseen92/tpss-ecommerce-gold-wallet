import 'package:dio/dio.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<ProductRemoteModel>> getProducts({int pageNumber = 1, int pageSize = 20}) async {
    final response = await _dio.post(
      '/products/search',
      data: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    final payload = response.data as Map<String, dynamic>;
    final data = payload['data'] as Map<String, dynamic>?;
    final items = (data?['items'] as List<dynamic>? ?? []);
    return items.map((item) => ProductRemoteModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}

class ProductRemoteModel {
  ProductRemoteModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.price,
    required this.availableStock,
    required this.sellerId,
    required this.sellerName,
  });

  final int id;
  final String name;
  final String sku;
  final String description;
  final double price;
  final int availableStock;
  final int sellerId;
  final String sellerName;

  factory ProductRemoteModel.fromJson(Map<String, dynamic> json) {
    return ProductRemoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '') as String,
      sku: (json['sku'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      sellerId: (json['sellerId'] as num?)?.toInt() ?? 0,
      sellerName: (json['sellerName'] ?? '') as String,
    );
  }
}
