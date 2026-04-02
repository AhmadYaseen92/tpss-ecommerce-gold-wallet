import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/asset_model.dart';

part 'sell_state.dart';

class SellCubit extends Cubit<SellState> {
  static const int _priceLockDurationSeconds = 30;

  double units = 0.0;
  bool agreedToTerms = false;
  int selectedAssetIndex = 0;
  int selectedBankAccountIndex = 0;
  double currentPricePerUnit = Asset.assets.first.pricePerUnit;
  int priceLockSecondsRemaining = _priceLockDurationSeconds;
  String? statusMessage;
  Timer? _priceTimer;
  int _refreshCount = 0;

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
    currentPricePerUnit = selectedAsset.pricePerUnit;
    _restartPriceLockTimer();
    _emitChanged();
  }

  void selectBankAccount(int index) {
    selectedBankAccountIndex = index;
    _emitChanged();
  }

  Future<bool> submit() async {
    if (units <= 0) {
      statusMessage = 'Enter a valid amount before confirming.';
      _emitChanged();
      return false;
    }
    if (!agreedToTerms) {
      statusMessage = 'Please agree to Terms & Conditions first.';
      _emitChanged();
      return false;
    }
    emit(SellLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    emit(SellSuccess());
    statusMessage = 'Sell confirmed at locked price.';
    _emitChanged();
    return true;
  }

  void loadSellData() async {
    emit(SellLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    currentPricePerUnit = selectedAsset.pricePerUnit;
    _restartPriceLockTimer();
    _emitChanged();
  }

  void _restartPriceLockTimer() {
    _priceTimer?.cancel();
    priceLockSecondsRemaining = _priceLockDurationSeconds;
    _priceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (priceLockSecondsRemaining > 1) {
        priceLockSecondsRemaining--;
      } else {
        _refreshPrice();
        priceLockSecondsRemaining = _priceLockDurationSeconds;
      }
      _emitChanged();
    });
  }

  void _refreshPrice() {
    _refreshCount++;
    final basePrice = selectedAsset.pricePerUnit;
    final factor = ((_refreshCount + selectedAssetIndex) % 5) - 2;
    final changePercent = factor * 0.006; // ±1.2% max change on every refresh.
    currentPricePerUnit = (basePrice * (1 + changePercent)).clamp(0.01, double.infinity);
    statusMessage =
        'Price updated to \$${currentPricePerUnit.toStringAsFixed(2)}. You have 30 seconds to confirm.';
  }

  void _emitChanged() {
    emit(
      SellDataChanged(
        units: units,
        agreedToTerms: agreedToTerms,
        selectedAssetIndex: selectedAssetIndex,
        currentPricePerUnit: currentPricePerUnit,
        priceLockSecondsRemaining: priceLockSecondsRemaining,
        statusMessage: statusMessage,
      ),
    );
  }

  Asset get selectedAsset => Asset.assets[selectedAssetIndex];
  double get subtotal => units * currentPricePerUnit;
  double get fee => subtotal * SellState.feePercent;
  double get net => subtotal - fee;

  @override
  Future<void> close() {
    amountController.dispose();
    _priceTimer?.cancel();
    return super.close();
  }
}
