import 'dart:async';

import 'package:tpss_ecommerce_gold_wallet/features/market_orders/data/datasources/market_order_legacy_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/models/wallet_model.dart';

class WalletLocalDataSource {
  final StreamController<List<WalletModel>> _walletController =
      StreamController<List<WalletModel>>.broadcast();

  Timer? _marketTimer;
  int _tick = 0;

  Future<List<WalletModel>> loadWallets() async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    MarketOrderRepository.orders;
    return List<WalletModel>.from(dummyWallets);
  }

  Stream<List<WalletModel>> watchWallets() {
    _startFeedIfNeeded();
    _walletController.add(List<WalletModel>.from(dummyWallets));
    return _walletController.stream;
  }

  void dispose() {
    _marketTimer?.cancel();
    _walletController.close();
  }

  void _startFeedIfNeeded() {
    if (_marketTimer != null) return;

    _marketTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _tick++;
      _refreshLivePricing();
      _walletController.add(List<WalletModel>.from(dummyWallets));
    });
  }

  void _refreshLivePricing() {
    final sourceWallets = List<WalletModel>.from(dummyWallets);

    for (int walletIndex = 0; walletIndex < dummyWallets.length; walletIndex++) {
      var wallet = dummyWallets[walletIndex];
      if (wallet.category == WalletCategory.spotMr) {
        final liveSpotWallet = sourceWallets.firstWhere(
          (w) => w.category == WalletCategory.spotMr,
          orElse: () => wallet,
        );
        wallet = wallet.copyWith(
          transactions: liveSpotWallet.transactions,
          totalHoldings: liveSpotWallet.totalHoldings,
          totalMarketValue: liveSpotWallet.totalMarketValue,
          totalWeightInGrams: liveSpotWallet.totalWeightInGrams,
        );
      }

      final updatedTransactions = wallet.transactions.asMap().entries.map((entry) {
        final txIndex = entry.key;
        final tx = entry.value;
        final oscillationSeed = ((_tick + walletIndex + txIndex) % 7) - 3;
        final deltaPercent = oscillationSeed * 0.003;
        final nextValue = (tx.marketValueAmount * (1 + deltaPercent)).clamp(0.01, double.infinity);
        final costBasis = tx.estimatedPurchaseValue;
        final pnlPercent = costBasis == 0 ? 0 : ((nextValue - costBasis) / costBasis) * 100;
        final signedPnl = pnlPercent >= 0 ? '+' : '';

        return tx.copyWith(
          marketValue: '\$${nextValue.toStringAsFixed(2)}',
          change: '$signedPnl${pnlPercent.toStringAsFixed(2)}%',
        );
      }).toList();

      final totalMarket = updatedTransactions.fold<double>(0, (sum, tx) => sum + tx.marketValueAmount);
      final totalPurchase = updatedTransactions.fold<double>(0, (sum, tx) => sum + tx.estimatedPurchaseValue);
      final walletPnlPercent = totalPurchase == 0 ? 0 : ((totalMarket - totalPurchase) / totalPurchase) * 100;
      final signed = walletPnlPercent >= 0 ? '+' : '';

      dummyWallets[walletIndex] = wallet.copyWith(
        transactions: updatedTransactions,
        totalMarketValue: '\$${totalMarket.toStringAsFixed(2)}',
        change: '$signed${walletPnlPercent.toStringAsFixed(2)}%',
      );
    }
  }
}
