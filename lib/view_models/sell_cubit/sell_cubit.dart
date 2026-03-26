import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/asset_model.dart';

part 'sell_state.dart';

class SellCubit extends Cubit<SellState> {
  double units = 0.0;
  bool agreedToTerms = false;
  int selectedAssetIndex = 0;
  int selectedBankAccountIndex = 0;

  final List<String> predefinedBankAccounts = const [
    'Main Account •••• 1234',
    'Savings Account •••• 7788',
  ];

  SellCubit() : super(SellInitial());

  final TextEditingController amountController = TextEditingController();

  void updateUnits(String value) {
    units = double.tryParse(value) ?? 0.0;
    _emitChanged();
  }

  void toggleTerms(bool? value) {
    agreedToTerms = value ?? false;
    _emitChanged();
  }

  void selectAsset(int index) {
    selectedAssetIndex = index;
    _emitChanged();
  }

  void selectBankAccount(int index) {
    selectedBankAccountIndex = index;
    _emitChanged();
  }

  void submit() async {
    emit(SellLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    emit(SellSuccess());
    _emitChanged();
  }

  void loadSellData() async {
    emit(SellLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    _emitChanged();
  }

  void _emitChanged() {
    emit(
      SellDataChanged(
        units: units,
        agreedToTerms: agreedToTerms,
        selectedAssetIndex: selectedAssetIndex,
      ),
    );
  }

  Asset get selectedAsset => Asset.assets[selectedAssetIndex];
  double get subtotal => units * selectedAsset.pricePerUnit;
  double get fee => subtotal * SellState.feePercent;
  double get net => subtotal - fee;

  @override
  Future<void> close() {
    amountController.dispose();
    return super.close();
  }
}
