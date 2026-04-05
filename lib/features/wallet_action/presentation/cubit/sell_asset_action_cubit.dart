import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/data/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';

part 'sell_asset_action_state.dart';

class SellAssetActionCubit extends Cubit<SellAssetActionState> {
  SellAssetActionCubit({required this.initialAsset})
      : quantityController = TextEditingController(text: '1'),
        noteController = TextEditingController(),
        super(SellAssetActionInitial()) {
    quantityController.addListener(_emitUpdated);
  }

  final WalletActionSummary initialAsset;
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

  double get grossAmount => unitPrice * quantity;
  double get feeAmount => grossAmount * 0.008;
  double get receivedAmount => grossAmount - feeAmount;

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

  WalletActionSummary buildSummary() {
    final payout = isBankPayout
        ? 'Bank - ${predefinedBankAccounts[selectedBankAccountIndex].name}'
        : 'Payment - ${predefinedPaymentMethods[selectedPaymentMethodIndex].name}';

    return WalletActionSummary(
      asset: initialAsset.asset,
      actionType: WalletActionType.sell,
      title: 'Sell Asset',
      primaryValue: '$quantity Units',
      feeValue: formatCurrency(feeAmount),
      totalValue: formatCurrency(receivedAmount),
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

  void _emitUpdated() => emit(SellAssetActionUpdated());

  @override
  Future<void> close() {
    quantityController.dispose();
    noteController.dispose();
    return super.close();
  }
}
