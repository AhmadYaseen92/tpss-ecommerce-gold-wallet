part of 'account_summary_cubit.dart';

sealed class AccountSummaryState {}

final class AccountSummaryInitial extends AccountSummaryState {}

final class AccountSummaryFormState extends AccountSummaryState {
  final ConvertMethod selectedMethod;
  final int selectedBankIndex;
  final int selectedPaymentIndex;
  final int selectedUsdtIndex;
  final int selectedEDirhamIndex;
  final String amount;
  final String note;
  final String? errorMessage;

  AccountSummaryFormState({
    required this.selectedMethod,
    required this.selectedBankIndex,
    required this.selectedPaymentIndex,
    required this.selectedUsdtIndex,
    required this.selectedEDirhamIndex,
    required this.amount,
    required this.note,
    this.errorMessage,
  });

  factory AccountSummaryFormState.initial() {
    return AccountSummaryFormState(
      selectedMethod: ConvertMethod.transferToBank,
      selectedBankIndex: 0,
      selectedPaymentIndex: 0,
      selectedUsdtIndex: 0,
      selectedEDirhamIndex: 0,
      amount: '',
      note: '',
      errorMessage: null,
    );
  }
}
