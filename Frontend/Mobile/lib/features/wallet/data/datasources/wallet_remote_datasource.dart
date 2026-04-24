import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/utils/server_url_resolver.dart';

class WalletRemoteDataSource {
  WalletRemoteDataSource(this._dio);

  final Dio _dio;

  Future<WalletRemoteModel> getWalletByCurrentUser() async {
    final userId = AuthSessionStore.userId;
    if (userId == null) {
      return WalletRemoteModel(
        id: 0,
        userId: 0,
        cashBalance: 0,
        currencyCode: 'USD',
        assets: const <WalletAssetRemoteModel>[],
      );
    }

    try {
      final response = await _dio.post('/wallet/by-user', data: {'userId': userId});
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? {};
      return WalletRemoteModel.fromJson(data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      if (statusCode == 400 || statusCode == 404) {
        return WalletRemoteModel(
          id: 0,
          userId: userId,
          cashBalance: 0,
          currencyCode: 'USD',
          assets: const <WalletAssetRemoteModel>[],
        );
      }
      rethrow;
    }
  }

  Future<Map<int, WalletPurchaseSnapshot>> getLatestApprovedBuySnapshots() async {
    final userId = AuthSessionStore.userId;
    if (userId == null) {
      return const <int, WalletPurchaseSnapshot>{};
    }

    final response = await _dio.post(
      '/transaction-history/filter',
      data: {
        'userId': userId,
        'pageNumber': 1,
        'pageSize': 200,
      },
    );

    final payload = response.data as Map<String, dynamic>;
    final data = payload['data'] as Map<String, dynamic>? ?? {};
    final items = (data['items'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>();

    final snapshots = <int, WalletPurchaseSnapshot>{};
    for (final item in items) {
      final walletItemId = (item['walletItemId'] as num?)?.toInt();
      if (walletItemId == null || walletItemId <= 0) continue;

      final type = (item['transactionType'] ?? '').toString().toLowerCase();
      final status = (item['status'] ?? '').toString().toLowerCase();
      if (type != 'buy' || status != 'approved') continue;

      snapshots.putIfAbsent(
        walletItemId,
        () => WalletPurchaseSnapshot(
          walletItemId: walletItemId,
          productName: (item['productName'] ?? '').toString(),
          purity: (item['purity'] as num?)?.toDouble() ?? 0,
          amount: (item['amount'] as num?)?.toDouble() ?? 0,
          currency: (item['currency'] ?? 'USD').toString(),
        ),
      );
    }

    return snapshots;
  }
}

class WalletPurchaseSnapshot {
  WalletPurchaseSnapshot({
    required this.walletItemId,
    required this.productName,
    required this.purity,
    required this.amount,
    required this.currency,
  });

  final int walletItemId;
  final String productName;
  final double purity;
  final double amount;
  final String currency;
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
    required this.productName,
    required this.productSku,
    required this.category,
    required this.sellerId,
    required this.weight,
    required this.unit,
    required this.purity,
    required this.quantity,
    required this.sellerName,
    required this.averageBuyPrice,
    required this.currentMarketPrice,
    required this.acquisitionFinalAmount,
    required this.productImageUrl,
    required this.isDelivered,
    required this.invoiceId,
    required this.certificateUrl,
    required this.sourceInvestorName,
    required this.status,
    required this.statusDetails,
  });

  final int id;
  final String assetType;
  final String productName;
  final String? productSku;
  final String category;
  final int? sellerId;
  final double weight;
  final String unit;
  final double purity;
  final int quantity;
  final String sellerName;
  final double averageBuyPrice;
  final double currentMarketPrice;
  final double acquisitionFinalAmount;
  final String? productImageUrl;
  final bool isDelivered;
  final int? invoiceId;
  final String? certificateUrl;
  final String? sourceInvestorName;
  final String status;
  final String? statusDetails;

  factory WalletAssetRemoteModel.fromJson(Map<String, dynamic> json) {
    final resolvedProductImageUrl = resolveServerUrl((json['productImageUrl'] ?? '').toString());
    return WalletAssetRemoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      assetType: (json['assetType'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      productSku: (json['productSku'] ?? '').toString().trim().isEmpty
          ? null
          : (json['productSku'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      sellerId: (json['sellerId'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      unit: (json['unit'] ?? 'gram').toString(),
      purity: (json['purity'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      sellerName: (json['sellerName'] ?? '').toString(),
      averageBuyPrice: (json['averageBuyPrice'] as num?)?.toDouble() ?? 0,
      currentMarketPrice: (json['currentMarketPrice'] as num?)?.toDouble() ?? 0,
      acquisitionFinalAmount: (json['acquisitionFinalAmount'] as num?)?.toDouble() ?? 0,
      productImageUrl: resolvedProductImageUrl.trim().isEmpty
          ? null
          : resolvedProductImageUrl,
      isDelivered: (json['isDelivered'] as bool?) ?? false,
      invoiceId: (json['invoiceId'] as num?)?.toInt(),
      certificateUrl: (json['certificateUrl'] ?? '').toString().isEmpty
          ? null
          : (json['certificateUrl'] ?? '').toString(),
      sourceInvestorName: (json['sourceInvestorName'] ?? '').toString().trim().isEmpty
          ? null
          : (json['sourceInvestorName'] ?? '').toString(),
      status: (json['status'] ?? 'Bought').toString(),
      statusDetails: (json['statusDetails'] as String?)?.trim().isEmpty ?? true
          ? null
          : (json['statusDetails'] as String?),
    );
  }
}
