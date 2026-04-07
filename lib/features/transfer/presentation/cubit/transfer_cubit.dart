import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/domain/entities/transfer_totals_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/domain/usecases/calculate_transfer_totals_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/domain/usecases/validate_transfer_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/domain/usecases/verify_transfer_account_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/models/asset_model.dart';

part 'transfer_state.dart';

class TransferCubit extends Cubit<TransferState> {
  TransferCubit({
    required ValidateTransferUseCase validateTransferUseCase,
    required CalculateTransferTotalsUseCase calculateTransferTotalsUseCase,
    required VerifyTransferAccountUseCase verifyTransferAccountUseCase,
  }) : _validateTransferUseCase = validateTransferUseCase,
       _calculateTransferTotalsUseCase = calculateTransferTotalsUseCase,
       _verifyTransferAccountUseCase = verifyTransferAccountUseCase,
       super(TransferInitial()) {
    recipientController.addListener(_onRecipientChanged);
  }

  final ValidateTransferUseCase _validateTransferUseCase;
  final CalculateTransferTotalsUseCase _calculateTransferTotalsUseCase;
  final VerifyTransferAccountUseCase _verifyTransferAccountUseCase;

  double units = 0.0;
  int selectedAssetIndex = 0;
  RecipientMode recipientMode = RecipientMode.account;
  bool agreedToTerms = false;
  bool isAccountVerified = false;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController recipientController = TextEditingController();

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

  Future<void> verifyAccount() async {
    final accountNo = recipientController.text.trim();
    if (accountNo.isEmpty) {
      isAccountVerified = false;
      _emitChanged();
      return;
    }
    isAccountVerified = await _verifyTransferAccountUseCase(accountNo);
    _emitChanged();
  }

  void _onRecipientChanged() {
    if (recipientMode != RecipientMode.account) return;
    verifyAccount();
  }

  void toggleTerms(bool? value) {
    agreedToTerms = value ?? false;
    _emitChanged();
  }

  void submit() async {
    final recipient = recipientController.text.trim();
    final errorMessage = await _validateTransferUseCase(
      units: units,
      availableUnits: selectedAsset.availableUnits,
      recipient: recipient,
      requiresAccountVerification: recipientMode == RecipientMode.account,
      agreedToTerms: agreedToTerms,
    );
    if (errorMessage != null) {
      emit(TransferError(errorMessage));
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
  TransferTotalsEntity get totals => _calculateTransferTotalsUseCase(
    units: units,
    pricePerUnit: selectedAsset.pricePerUnit,
  );
  double get subtotal => totals.subtotal;
  double get fee => totals.fee;
  double get totalDeducted => totals.totalDeducted;

  @override
  Future<void> close() {
    recipientController.removeListener(_onRecipientChanged);
    amountController.dispose();
    recipientController.dispose();
    return super.close();
  }
}
