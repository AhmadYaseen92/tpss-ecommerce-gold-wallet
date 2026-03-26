import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/asset_model.dart';

part 'transfer_state.dart';

class TransferCubit extends Cubit<TransferState> {
  double units = 0.0;
  int selectedAssetIndex = 0;
  RecipientMode recipientMode = RecipientMode.account;
  bool agreedToTerms = false;
  bool isAccountVerified = false;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController recipientController = TextEditingController();

  final Set<String> _registeredAccounts = {'10001', '10002', '20011', '77889'};

  TransferCubit() : super(TransferInitial());

  void load() async {
    emit(TransferLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    _emitChanged();
  }

  void updateUnits(String value) {
    units = double.tryParse(value) ?? 0.0;
    _emitChanged();
  }

  void selectAsset(int index) {
    selectedAssetIndex = index;
    _emitChanged();
  }

  void setRecipientMode(RecipientMode mode) {
    recipientMode = mode;
    recipientController.clear();
    isAccountVerified = false;
    _emitChanged();
  }

  void verifyAccount() {
    final accountNo = recipientController.text.trim();
    isAccountVerified = _registeredAccounts.contains(accountNo);
    _emitChanged();
  }

  void toggleTerms(bool? value) {
    agreedToTerms = value ?? false;
    _emitChanged();
  }

  void submit() async {
    final recipient = recipientController.text.trim();
    if (units <= 0) {
      emit(TransferError('Please enter a valid amount.'));
      _emitChanged();
      return;
    }
    if (units > selectedAsset.availableUnits) {
      emit(TransferError('Amount exceeds available balance.'));
      _emitChanged();
      return;
    }
    if (recipient.isEmpty) {
      emit(TransferError('Please enter recipient details.'));
      _emitChanged();
      return;
    }
    if (recipientMode == RecipientMode.account && !isAccountVerified) {
      emit(TransferError('Recipient account must exist and be verified.'));
      _emitChanged();
      return;
    }
    if (!agreedToTerms) {
      emit(TransferError('Please agree to the terms and conditions.'));
      _emitChanged();
      return;
    }
    emit(TransferLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    emit(TransferSuccess());
  }

  void _emitChanged() {
    emit(
      TransferDataChanged(
        units: units,
        selectedAssetIndex: selectedAssetIndex,
        recipientMode: recipientMode,
        agreedToTerms: agreedToTerms,
        isAccountVerified: isAccountVerified,
      ),
    );
  }

  Asset get selectedAsset => Asset.assets[selectedAssetIndex];
  double get subtotal => units * selectedAsset.pricePerUnit;
  double get fee => subtotal * TransferState.feePercent;
  double get totalDeducted => subtotal + fee;

  @override
  Future<void> close() {
    amountController.dispose();
    recipientController.dispose();
    return super.close();
  }
}
