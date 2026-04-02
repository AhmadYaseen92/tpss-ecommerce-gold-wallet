import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final List<WalletModel> _wallets = List<WalletModel>.from(dummyWallets);
  int _selectedIndex = 0;
  Timer? _marketTimer;
  int _tick = 0;

  WalletCubit() : super(WalletInitial());

  void loadWallets() async {
    emit(WalletLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      _selectedIndex = 0;
      _emitWallets();
      _startMarketFeed();
    } catch (e) {
      emit(WalletError('Failed to load wallets: $e'));
    }
  }

  void selectTab(int index) {
    _selectedIndex = index;
    _emitWallets();
  }

  void _startMarketFeed() {
    _marketTimer?.cancel();
    _marketTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _tick++;
      _refreshLivePricing();
      _emitWallets();
    });
  }

  void _refreshLivePricing() {
    for (int walletIndex = 0; walletIndex < _wallets.length; walletIndex++) {
      final wallet = _wallets[walletIndex];
      final updatedTransactions = wallet.transactions.asMap().entries.map((entry) {
        final txIndex = entry.key;
        final tx = entry.value;
        final oscillationSeed = ((_tick + walletIndex + txIndex) % 7) - 3; // -3 to +3
        final deltaPercent = oscillationSeed * 0.003; // max ±0.9% every tick
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

      _wallets[walletIndex] = wallet.copyWith(
        transactions: updatedTransactions,
        totalMarketValue: '\$${totalMarket.toStringAsFixed(2)}',
        change: '$signed${walletPnlPercent.toStringAsFixed(2)}%',
      );
    }
  }

  void _emitWallets() {
    emit(WalletLoaded(wallets: List.unmodifiable(_wallets), selectedIndex: _selectedIndex));
  }

  @override
  Future<void> close() {
    _marketTimer?.cancel();
    return super.close();
  }
}
