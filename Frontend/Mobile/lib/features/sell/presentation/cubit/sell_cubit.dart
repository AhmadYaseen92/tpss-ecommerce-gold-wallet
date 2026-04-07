import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/entities/sell_totals_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/usecases/calculate_sell_totals_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/usecases/get_live_sell_price_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/usecases/load_sell_data_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/usecases/submit_sell_order_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/usecases/validate_sell_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/models/asset_model.dart';

part 'sell_state.dart';

class SellCubit extends Cubit<SellState> {
  static const int _priceLockDurationSeconds = 30;

  SellCubit({
    required LoadSellDataUseCase loadSellDataUseCase,
    required GetLiveSellPriceUseCase getLiveSellPriceUseCase,
    required ValidateSellUseCase validateSellUseCase,
    required SubmitSellOrderUseCase submitSellOrderUseCase,
    required CalculateSellTotalsUseCase calculateSellTotalsUseCase,
  }) : _loadSellDataUseCase = loadSellDataUseCase,
       _getLiveSellPriceUseCase = getLiveSellPriceUseCase,
       _validateSellUseCase = validateSellUseCase,
       _submitSellOrderUseCase = submitSellOrderUseCase,
       _calculateSellTotalsUseCase = calculateSellTotalsUseCase,
       super(SellInitial());

  final LoadSellDataUseCase _loadSellDataUseCase;
  final GetLiveSellPriceUseCase _getLiveSellPriceUseCase;
  final ValidateSellUseCase _validateSellUseCase;
  final SubmitSellOrderUseCase _submitSellOrderUseCase;
  final CalculateSellTotalsUseCase _calculateSellTotalsUseCase;

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
    final errorMessage = _validateSellUseCase(units: units, agreedToTerms: agreedToTerms);
    if (errorMessage != null) {
      statusMessage = errorMessage;
      _emitChanged();
      return false;
    }
    emit(SellLoading());
    await _submitSellOrderUseCase();
    emit(SellSuccess());
    statusMessage = 'Sell confirmed at locked price.';
    _emitChanged();
    return true;
  }

  void loadSellData() async {
    emit(SellLoading());
    await _loadSellDataUseCase();
    currentPricePerUnit = _getLiveSellPriceUseCase(assetIndex: selectedAssetIndex, refreshCount: _refreshCount);
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
    currentPricePerUnit = _getLiveSellPriceUseCase(
      assetIndex: selectedAssetIndex,
      refreshCount: _refreshCount,
    );
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
  SellTotalsEntity get totals => _calculateSellTotalsUseCase(
    units: units,
    pricePerUnit: currentPricePerUnit,
  );
  double get subtotal => totals.subtotal;
  double get fee => totals.fee;
  double get net => totals.net;

  @override
  Future<void> close() {
    amountController.dispose();
    _priceTimer?.cancel();
    return super.close();
  }
}
