import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';

class WalletActionRemoteDataSource {
  WalletActionRemoteDataSource(this._dio);

  final Dio _dio;

  Future<bool> isMarketOpen() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  Future<double> availableLiquidity() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return 1000000;
  }

  Future<double> lockUnitPrice(double requestedUnitPrice) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return requestedUnitPrice;
  }

  Future<SellExecutionMode> getSellExecutionMode() async {
    final response = await _dio.get('/wallet/actions/sell-configuration');
    final payload = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
    final mode = (payload['mode'] ?? '').toString().toLowerCase();
    return mode == 'live_price' ? SellExecutionMode.livePrice : SellExecutionMode.locked30Seconds;
  }

  Future<WalletActionExecutionResult> executeWalletAction(WalletActionExecutionRequest request) async {
    final userId = AuthSessionStore.userId;
    if (userId == null) {
      throw Exception('No logged-in user. Please login first.');
    }

    final response = await _dio.post(
      '/wallet/actions/execute',
      data: {
        'userId': userId,
        'walletAssetId': request.walletAssetId,
        'actionType': _mapActionType(request.actionType),
        'quantity': request.quantity,
        'unitPrice': request.unitPrice,
        'weight': request.weight,
        'amount': request.amount,
        'recipientInvestorUserId': request.recipientInvestorUserId,
        'notes': request.notes,
      },
    );

    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
    return WalletActionExecutionResult(
      referenceId: (data['referenceId'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
      cashBalance: (data['cashBalance'] as num?)?.toDouble() ?? 0,
      totalPortfolioValue: (data['totalPortfolioValue'] as num?)?.toDouble() ?? 0,
      lockedPriceUntilUtc: DateTime.tryParse((data['lockedPriceUntilUtc'] ?? '').toString()),
    );
  }

  Future<List<InvestorRecipient>> searchInvestors(String query) async {
    final response = await _dio.get('/wallet/investors', queryParameters: {'query': query});
    final payload = (response.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
    return payload
        .map((item) => InvestorRecipient.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<InvestorRecipient?> lookupInvestor(String accountNumber) async {
    final response = await _dio.get('/wallet/investors/lookup', queryParameters: {'accountNumber': accountNumber});
    final payload = (response.data as Map<String, dynamic>)['data'];
    if (payload is! Map<String, dynamic>) return null;
    return InvestorRecipient.fromJson(payload);
  }

  String _mapActionType(WalletActionType type) => switch (type) {
    WalletActionType.sell => 'sell',
    WalletActionType.transfer => 'transfer',
    WalletActionType.gift => 'gift',
    WalletActionType.convertToCash => 'certificate',
    WalletActionType.convertToCrypto => 'invoice',
  };
}
