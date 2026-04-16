import 'package:dio/dio.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ProductRemotePageModel> getProducts({int pageNumber = 1, int pageSize = 20, int? categoryId}) async {
    final response = await _dio.post(
      '/products/search',
      data: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (categoryId != null) 'category': categoryId,
      },
    );

    final payload = response.data as Map<String, dynamic>;
    final data = payload['data'] as Map<String, dynamic>?;
    final items = (data?['items'] as List<dynamic>? ?? []);
    return ProductRemotePageModel(
      items: items.map((item) => ProductRemoteModel.fromJson(item as Map<String, dynamic>)).toList(),
      totalCount: (data?['totalCount'] as num?)?.toInt() ?? 0,
      pageNumber: (data?['pageNumber'] as num?)?.toInt() ?? pageNumber,
      pageSize: (data?['pageSize'] as num?)?.toInt() ?? pageSize,
    );
  }
}

class ProductRemotePageModel {
  ProductRemotePageModel({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  final List<ProductRemoteModel> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
}

class ProductRemoteModel {
  ProductRemoteModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.availableStock,
    required this.categoryId,
    required this.pricingMaterialType,
    required this.pricingMode,
    required this.weightValue,
    required this.weightUnit,
    required this.purityKarat,
    required this.marketUnitPrice,
    required this.deliveryFee,
    required this.storageFee,
    required this.serviceCharge,
    required this.finalSellPrice,
    required this.sellerId,
    required this.sellerName,
  });

  final int id;
  final String name;
  final String sku;
  final String description;
  final String imageUrl;
  final double price;
  final int availableStock;
  final int categoryId;
  final String pricingMaterialType;
  final String pricingMode;
  final double weightValue;
  final String weightUnit;
  final double purityKarat;
  final double marketUnitPrice;
  final double deliveryFee;
  final double storageFee;
  final double serviceCharge;
  final double finalSellPrice;
  final int sellerId;
  final String sellerName;

  factory ProductRemoteModel.fromJson(Map<String, dynamic> json) {
    return ProductRemoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '') as String,
      sku: (json['sku'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? '') as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      categoryId: _parseCategoryId(json['category']),
      pricingMaterialType: (json['pricingMaterialType'] ?? 'Gold') as String,
      pricingMode: (json['pricingMode'] ?? 'Auto') as String,
      weightValue: (json['weightValue'] as num?)?.toDouble() ?? 0,
      weightUnit: _parseWeightUnit(json['weightUnit']),
      purityKarat: (json['purityKarat'] as num?)?.toDouble() ?? 0,
      marketUnitPrice: (json['marketUnitPrice'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      storageFee: (json['storageFee'] as num?)?.toDouble() ?? 0,
      serviceCharge: (json['serviceCharge'] as num?)?.toDouble() ?? 0,
      finalSellPrice: (json['finalSellPrice'] as num?)?.toDouble() ?? ((json['price'] as num?)?.toDouble() ?? 0),
      sellerId: (json['sellerId'] as num?)?.toInt() ?? 0,
      sellerName: (json['sellerName'] ?? '') as String,
    );
  }

  static int _parseCategoryId(dynamic categoryValue) {
    if (categoryValue is num) {
      return categoryValue.toInt();
    }
    if (categoryValue is String) {
      final parsed = int.tryParse(categoryValue);
      if (parsed != null) return parsed;

      return switch (categoryValue.trim().toLowerCase()) {
        'gold' => 1,
        'silver' => 2,
        'diamond' => 3,
        'jewelry' => 4,
        'coins' => 5,
        'spotmr' || 'spot mr' => 6,
        _ => 1,
      };
    }
    return 1;
  }

  static String _parseWeightUnit(dynamic weightUnitValue) {
    if (weightUnitValue is String) {
      return weightUnitValue;
    }
    if (weightUnitValue is num) {
      return switch (weightUnitValue.toInt()) {
        1 => 'Gram',
        2 => 'Kilogram',
        3 => 'Ounce',
        _ => '',
      };
    }
    return '';
  }
}
