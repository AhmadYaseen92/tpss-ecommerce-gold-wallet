import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';

abstract class IWalletActionRepository {
  Future<bool> isMarketOpen();

  Future<double> availableLiquidity();

  Future<double> lockUnitPrice(double requestedUnitPrice);

  Future<SellExecutionMode> getSellExecutionMode();
  Future<WalletActionPreviewResult> previewWalletAction({
    required WalletActionType actionType,
    required int walletAssetId,
    required int quantity,
    required double unitPrice,
    required double weight,
    required double amount,
  });

  Future<WalletActionExecutionResult> executeWalletAction(WalletActionExecutionRequest request);
  Future<void> cancelWalletRequest({required int walletAssetId});

  Future<List<InvestorRecipient>> searchInvestors(String query);

  Future<InvestorRecipient?> lookupInvestor(String accountNumber);
}
