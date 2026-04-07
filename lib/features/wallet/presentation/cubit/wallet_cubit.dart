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
  int _selectedIndex = 0;
  StreamSubscription<List<WalletEntity>>? _walletSubscription;

  Future<void> loadWallets() async {
    emit(WalletLoading());
    try {
      _wallets
        ..clear()
        ..addAll(await _loadWalletsUseCase());
      _selectedIndex = 0;
      _emitWallets();
      await _startWalletWatch();
    } catch (e) {
      emit(WalletError('Failed to load wallets: $e'));
    }
  }

  void selectTab(int index) {
    _selectedIndex = index;
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
    emit(WalletLoaded(wallets: List.unmodifiable(_wallets), selectedIndex: _selectedIndex));
  }

  @override
  Future<void> close() async {
    await _walletSubscription?.cancel();
    return super.close();
  }
}
