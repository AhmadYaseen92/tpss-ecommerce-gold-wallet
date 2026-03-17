import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/asset_model.dart';

part 'sell_state.dart';

class SellCubit extends Cubit<SellState> {
  double units = 0.0;
  bool agreedToTerms = false;
  int selectedAssetIndex = 0;

  SellCubit() : super(SellInitial());

  final TextEditingController amountController = TextEditingController();

  void updateUnits(String value) {
    units = double.tryParse(value) ?? 0.0;
    emit(
      SellDataChanged(
        units: units,
        agreedToTerms: agreedToTerms,
        selectedAssetIndex: selectedAssetIndex,
      ),
    );
  }

  void toggleTerms(bool? value) {
    agreedToTerms = value ?? false;
    emit(
      SellDataChanged(
        units: units,
        agreedToTerms: agreedToTerms,
        selectedAssetIndex: selectedAssetIndex,
      ),
    );
  }

  void selectAsset(int index) {
    selectedAssetIndex = index;
    emit(
      SellDataChanged(
        units: units,
        agreedToTerms: agreedToTerms,
        selectedAssetIndex: selectedAssetIndex,
      ),
    );
  }

  void submit() async {
    emit(SellLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      emit(SellSuccess());
    } catch (e) {
      emit(SellError('Failed to process sale: $e'));
    }
  }

  void loadSellData() async {
    emit(SellLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      emit(
        SellDataChanged(
          units: units,
          agreedToTerms: agreedToTerms,
          selectedAssetIndex: selectedAssetIndex,
        ),
      );
    } catch (e) {
      emit(SellError('Failed to load sell data: $e'));
    }
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
