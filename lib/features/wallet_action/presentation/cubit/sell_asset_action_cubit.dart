import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/entities/sell_asset_entities.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/repositories/wallet_action_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/usecases/prepare_sell_asset_usecase.dart';

part 'sell_asset_action_state.dart';

class SellAssetActionCubit extends Cubit<SellAssetActionState> {
  SellAssetActionCubit({
    required this.initialAsset,
    required IWalletActionRepository repository,
    PrepareSellAssetUseCase? prepareSellAssetUseCase,
  }) : _repository = repository,
       _prepareSellAssetUseCase = prepareSellAssetUseCase ?? const PrepareSellAssetUseCase(),
       quantityController = TextEditingController(text: '1'),
       noteController = TextEditingController(),
       super(SellAssetActionInitial()) {
    quantityController.addListener(_emitUpdated);
    _emitUpdated();
  }

  final WalletActionSummary initialAsset;
  final IWalletActionRepository _repository;
  final PrepareSellAssetUseCase _prepareSellAssetUseCase;
  final TextEditingController quantityController;
  final TextEditingController noteController;

  String payoutMethod = 'Bank Account';
  int selectedBankAccountIndex = 0;
  int selectedPaymentMethodIndex = 0;

  List<PredefinedAccount> get predefinedBankAccounts => PredefinedAccountsData.bankAccounts;
  List<PredefinedAccount> get predefinedPaymentMethods => PredefinedAccountsData.paymentMethods;

  int get maxQuantity => initialAsset.asset.quantity;

  double get unitPrice => _parseCurrency(initialAsset.asset.marketValue) / maxQuantity;

  int get quantity {
    final parsed = int.tryParse(quantityController.text.trim()) ?? 1;
    if (parsed < 1) return 1;
    if (parsed > maxQuantity) return maxQuantity;
    return parsed;
  }

  bool get isBankPayout => payoutMethod == 'Bank Account';
  bool get isPaymentMethodPayout => payoutMethod == 'Payment Method';

  SellAssetResultEntity? get calculatedResult {
    final current = state;
    if (current is SellAssetActionUpdated) return current.result;
    return null;
  }

  String? get errorMessage {
    final current = state;
    if (current is SellAssetActionUpdated) return current.errorMessage;
    return null;
  }

  String formatCurrency(double value) => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);

  String? validateQuantity(String? value) {
    final qty = int.tryParse((value ?? '').trim());
    if (qty == null) return 'Please enter a valid number';
    if (qty < 1) return 'Quantity must be at least 1';
    if (qty > maxQuantity) return 'Quantity cannot exceed $maxQuantity';
    return null;
  }

  void updatePayoutMethod(String? value) {
    if (value == null) return;
    payoutMethod = value;
    _emitUpdated();
  }

  void updateBankAccount(int? index) {
    if (index == null) return;
    selectedBankAccountIndex = index;
    _emitUpdated();
  }

  void updatePaymentMethod(int? index) {
    if (index == null) return;
    selectedPaymentMethodIndex = index;
    _emitUpdated();
  }

  Future<void> _emitUpdated() async {
    try {
      final marketOpen = await _repository.isMarketOpen();
      final liquidity = await _repository.availableLiquidity();
      final lockedPrice = await _repository.lockUnitPrice(unitPrice);

      final result = _prepareSellAssetUseCase(
        SellAssetRequestEntity(
          quantity: quantity,
          maxQuantity: maxQuantity,
          unitPrice: unitPrice,
          marketOpen: marketOpen,
          availableLiquidity: liquidity,
          lockedPrice: lockedPrice,
        ),
      );

      emit(SellAssetActionUpdated(result: result));
    } catch (e) {
      emit(SellAssetActionUpdated(result: null, errorMessage: e.toString()));
    }
  }

  WalletActionSummary buildSummary() {
    final result = calculatedResult;
    if (result == null) {
      throw Exception(errorMessage ?? 'Unable to prepare sell summary.');
    }

    final payout = isBankPayout
        ? 'Bank - ${predefinedBankAccounts[selectedBankAccountIndex].name}'
        : 'Payment - ${predefinedPaymentMethods[selectedPaymentMethodIndex].name}';

    return WalletActionSummary(
      asset: initialAsset.asset,
      actionType: WalletActionType.sell,
      title: 'Sell Asset',
      primaryValue: '${result.quantity} Units',
      feeValue: formatCurrency(result.feeAmount),
      totalValue: formatCurrency(result.receivedAmount),
      destinationLabel: 'Payout Method',
      destinationValue: payout,
      note: noteController.text.trim(),
      referenceNumber: 'SELL-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      isPending: true,
    );
  }

  double _parseCurrency(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0;
  }

  @override
  Future<void> close() {
    quantityController.dispose();
    noteController.dispose();
    return super.close();
  }
}
