import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';

abstract class IWalletActionRepository {
  Future<bool> isMarketOpen();

  Future<double> availableLiquidity();

  Future<double> lockUnitPrice(double requestedUnitPrice);

  Future<SellExecutionMode> getSellExecutionMode();

  Future<WalletActionExecutionResult> executeWalletAction(WalletActionExecutionRequest request);
}
