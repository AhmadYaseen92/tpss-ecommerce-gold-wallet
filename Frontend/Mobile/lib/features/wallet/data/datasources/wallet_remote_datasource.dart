import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';

class WalletRemoteDataSource {
  WalletRemoteDataSource(this._dio);

  final Dio _dio;

  Future<WalletRemoteModel> getWalletByCurrentUser() async {
    final userId = AuthSessionStore.userId;
    if (userId == null) {
      throw Exception('No logged-in user. Please login first.');
    }

    final response = await _dio.post('/wallet/by-user', data: {'userId': userId});
    final payload = response.data as Map<String, dynamic>;
    final data = payload['data'] as Map<String, dynamic>? ?? {};
    return WalletRemoteModel.fromJson(data);
  }
}

class WalletRemoteModel {
  WalletRemoteModel({
    required this.id,
    required this.userId,
    required this.cashBalance,
    required this.currencyCode,
    required this.assets,
  });

  final int id;
  final int userId;
  final double cashBalance;
  final String currencyCode;
  final List<WalletAssetRemoteModel> assets;

  factory WalletRemoteModel.fromJson(Map<String, dynamic> json) {
    final items = (json['assets'] as List<dynamic>? ?? []);
    return WalletRemoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      cashBalance: (json['cashBalance'] as num?)?.toDouble() ?? 0,
      currencyCode: (json['currencyCode'] ?? 'USD').toString(),
      assets: items.map((e) => WalletAssetRemoteModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class WalletAssetRemoteModel {
  WalletAssetRemoteModel({
    required this.id,
    required this.assetType,
    required this.weight,
    required this.unit,
    required this.purity,
    required this.quantity,
    required this.averageBuyPrice,
    required this.currentMarketPrice,
  });

  final int id;
  final String assetType;
  final double weight;
  final String unit;
  final double purity;
  final int quantity;
  final double averageBuyPrice;
  final double currentMarketPrice;

  factory WalletAssetRemoteModel.fromJson(Map<String, dynamic> json) {
    return WalletAssetRemoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      assetType: (json['assetType'] ?? '').toString(),
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      unit: (json['unit'] ?? 'gram').toString(),
      purity: (json['purity'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      averageBuyPrice: (json['averageBuyPrice'] as num?)?.toDouble() ?? 0,
      currentMarketPrice: (json['currentMarketPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}
