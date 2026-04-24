import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/core/services/action_summary_builder.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/repositories/wallet_action_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';

part 'transfer_asset_action_state.dart';

class TransferAssetActionCubit extends Cubit<TransferAssetActionState> {
  TransferAssetActionCubit({required this.asset, required IWalletActionRepository walletActionRepository})
    : recipientNameController = TextEditingController(),
      recipientContactController = TextEditingController(),
      quantityController = TextEditingController(text: '1'),
      messageController = TextEditingController(),
      _walletActionRepository = walletActionRepository,
      super(TransferAssetActionInitial()) {
    quantityController.addListener(_emitUpdated);
    recipientContactController.addListener(_onRecipientChanged);
    _emitUpdated();
  }

  final WalletTransactionEntity asset;
  final IWalletActionRepository _walletActionRepository;

  final TextEditingController recipientNameController;
  final TextEditingController recipientContactController;
  final TextEditingController quantityController;
  final TextEditingController messageController;

  WalletActionType transferType = WalletActionType.transfer;
  bool isRecipientVerified = false;
  int? recipientInvestorUserId;

  int get maxQuantity => asset.quantity;
  double get _grossBaseAmount => asset.investmentValue > 0
      ? asset.investmentValue
      : _parseCurrency(asset.displayValue);
  double get unitPrice => maxQuantity == 0 ? 0 : _grossBaseAmount / maxQuantity;

  int get quantity {
    final parsed = int.tryParse(quantityController.text.trim()) ?? 1;
    if (parsed < 1) return 1;
    if (parsed > maxQuantity) return maxQuantity;
    return parsed;
  }

  bool get isGift => transferType == WalletActionType.gift;
  double get grossAmount => unitPrice * quantity;
  WalletActionPreviewResult? _preview;
  List<WalletActionPreviewFeeLine> get feeBreakdowns =>
      _preview?.feeBreakdowns ?? const <WalletActionPreviewFeeLine>[];
  double get feeAmount => (_preview?.totalFeesAmount ?? 0) - (_preview?.discountAmount ?? 0);
  double get estimatedValue => _preview?.finalAmount ?? 0;

  String formatCurrency(double value) =>
      NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);

  String? validateRecipientName(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Recipient name is required';
    return null;
  }

  String? validateRecipientContact(String? value) {
    final account = (value ?? '').trim();
    if (account.isEmpty) return 'Recipient account number is required';
    if (!isRecipientVerified) {
      return 'Account is not verified.';
    }
    return null;
  }

  String? validateQuantity(String? value) {
    final qty = int.tryParse((value ?? '').trim());
    if (qty == null) return 'Please enter a valid number';
    if (qty < 1) return 'Quantity must be at least 1';
    if (qty > maxQuantity) return 'Quantity cannot exceed $maxQuantity';
    return null;
  }

  Future<void> verifyRecipientAccount() async {
    final accountNo = recipientContactController.text.trim();
    if (accountNo.isEmpty) {
      isRecipientVerified = false;
      recipientInvestorUserId = null;
      _emitUpdated();
      return;
    }

    try {
      final investor = await _walletActionRepository.lookupInvestor(accountNo);
      isRecipientVerified = investor != null;
      recipientInvestorUserId = investor?.investorUserId;
      if (investor != null && recipientNameController.text.trim().isEmpty) {
        recipientNameController.text = investor.investorName;
      }
    } catch (_) {
      isRecipientVerified = false;
      recipientInvestorUserId = null;
    }
    await _emitUpdated();
  }

  void _onRecipientChanged() {
    verifyRecipientAccount();
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
      summary: ActionSummaryBuilder.fromAny(_preview),
      preview: _preview,
      destinationLabel: 'Recipient Account No.',
      destinationValue: recipientContactController.text.trim(),
      recipientInvestorUserId: recipientInvestorUserId,
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

  Future<void> _emitUpdated() async {
    try {
      final quantityToSend = quantity;
      final requestedWeight = maxQuantity == 0 ? 0.0 : (asset.weightInGrams / maxQuantity) * quantityToSend;
      _preview = await _walletActionRepository.previewWalletAction(
        actionType: transferType,
        walletAssetId: asset.id,
        quantity: quantityToSend,
        unitPrice: unitPrice,
        weight: requestedWeight,
        amount: grossAmount,
      );
    } catch (_) {
      _preview = null;
    }
    emit(TransferAssetActionUpdated());
  }

  @override
  Future<void> close() {
    recipientContactController.removeListener(_onRecipientChanged);
    recipientNameController.dispose();
    recipientContactController.dispose();
    quantityController.dispose();
    messageController.dispose();
    return super.close();
  }
}
