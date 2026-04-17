import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/usecases/load_wallets_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/usecases/watch_wallets_usecase.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit({
    required LoadWalletsUseCase loadWalletsUseCase,
    required WatchWalletsUseCase watchWalletsUseCase,
  }) : _loadWalletsUseCase = loadWalletsUseCase,
       _watchWalletsUseCase = watchWalletsUseCase,
       super(WalletInitial());

  final LoadWalletsUseCase _loadWalletsUseCase;
  final WatchWalletsUseCase _watchWalletsUseCase;

  final List<WalletEntity> _wallets = <WalletEntity>[];
  int? _selectedCategoryId;
  StreamSubscription<List<WalletEntity>>? _walletSubscription;

  Future<void> loadWallets() async {
    emit(WalletLoading());
    try {
      _wallets
        ..clear()
        ..addAll(await _loadWalletsUseCase());
      _emitWallets();
      await _startWalletWatch();
    } catch (e) {
      emit(WalletError('Failed to load wallets: $e'));
    }
  }

  void selectCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    _emitWallets();
  }

  Future<void> _startWalletWatch() async {
    await _walletSubscription?.cancel();
    _walletSubscription = _watchWalletsUseCase().listen((wallets) {
      _wallets
        ..clear()
        ..addAll(wallets);
      _emitWallets();
    });
  }

  void _emitWallets() {
    final filtered = _selectedCategoryId == null
        ? List<WalletEntity>.from(_wallets)
        : _wallets.where((wallet) => _toCategoryId(wallet.category) == _selectedCategoryId).toList();
    final totalPortfolioValue = _wallets.fold<double>(0, (sum, item) {
      final parsed = double.tryParse(item.totalMarketValue.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      return sum + parsed;
    });

    emit(
      WalletLoaded(
        wallets: List.unmodifiable(filtered),
        selectedCategoryId: _selectedCategoryId,
        totalPortfolioValue: totalPortfolioValue,
      ),
    );
  }

  int _toCategoryId(WalletCategory category) => switch (category) {
    WalletCategory.gold => 1,
    WalletCategory.silver => 2,
    WalletCategory.diamond => 3,
    WalletCategory.jewelry => 4,
    WalletCategory.coins => 5,
    WalletCategory.spotMr => 6,
  };

  @override
  Future<void> close() async {
    await _walletSubscription?.cancel();
    return super.close();
  }
}
