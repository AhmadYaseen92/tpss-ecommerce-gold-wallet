import 'package:bloc/bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitial());

  void loadWallets() async {
    emit(WalletLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      emit(WalletLoaded(wallets: dummyWallets, selectedIndex: 0));
    } catch (e) {
      emit(WalletError('Failed to load wallets: $e'));
    }
  }

  void selectTab(int index) {
      emit(WalletLoaded(wallets: dummyWallets, selectedIndex: index));
  }
}
