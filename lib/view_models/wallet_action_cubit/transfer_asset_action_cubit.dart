import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';

part 'transfer_asset_action_state.dart';

class TransferAssetActionCubit extends Cubit<TransferAssetActionState> {
  TransferAssetActionCubit({required this.asset})
    : recipientNameController = TextEditingController(),
      recipientContactController = TextEditingController(),
      quantityController = TextEditingController(text: '1'),
      messageController = TextEditingController(),
      super(TransferAssetActionInitial()) {
    quantityController.addListener(_emitUpdated);
  }

  final WalletTransaction asset;

  final TextEditingController recipientNameController;
  final TextEditingController recipientContactController;
  final TextEditingController quantityController;
  final TextEditingController messageController;

  WalletActionType transferType = WalletActionType.transfer;

  int get maxQuantity => asset.quantity;
  double get unitPrice => _parseCurrency(asset.marketValue) / maxQuantity;

  int get quantity {
    final parsed = int.tryParse(quantityController.text.trim()) ?? 1;
    if (parsed < 1) return 1;
    if (parsed > maxQuantity) return maxQuantity;
    return parsed;
  }

  bool get isGift => transferType == WalletActionType.gift;
  double get grossAmount => unitPrice * quantity;
  double get feeAmount => 10;
  double get estimatedValue => grossAmount - feeAmount;

  String formatCurrency(double value) => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);

  String? validateRecipientName(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Recipient name is required';
    return null;
  }

  String? validateRecipientContact(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Recipient contact is required';
    return null;
  }

  String? validateQuantity(String? value) {
    final qty = int.tryParse((value ?? '').trim());
    if (qty == null) return 'Please enter a valid number';
    if (qty < 1) return 'Quantity must be at least 1';
    if (qty > maxQuantity) return 'Quantity cannot exceed $maxQuantity';
    return null;
  }

  void updateTransferType(WalletActionType value) {
    transferType = value;
    _emitUpdated();
  }

  WalletActionSummary buildSummary() {
    return WalletActionSummary(
      asset: asset,
      actionType: transferType,
      title: isGift ? 'Gift Asset' : 'Transfer Asset',
      primaryValue: '$quantity Units',
      feeValue: formatCurrency(feeAmount),
      totalValue: formatCurrency(estimatedValue),
      destinationLabel: isGift ? 'Recipient Contact' : 'Wallet ID / Contact',
      destinationValue: recipientContactController.text.trim(),
      note: messageController.text.trim(),
      referenceNumber: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      isPending: true,
    );
  }

  double _parseCurrency(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0;
  }

  void _emitUpdated() => emit(TransferAssetActionUpdated());

  @override
  Future<void> close() {
    recipientNameController.dispose();
    recipientContactController.dispose();
    quantityController.dispose();
    messageController.dispose();
    return super.close();
  }
}
