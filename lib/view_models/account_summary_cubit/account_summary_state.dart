part of 'account_summary_cubit.dart';

class AccountSummaryState {
  final ConvertMethod selectedMethod;
  final int selectedBankIndex;
  final int selectedPaymentIndex;
  final int selectedUsdtIndex;
  final int selectedEDirhamIndex;
  final String amount;
  final String note;
  final String? errorMessage;

  const AccountSummaryState({
    required this.selectedMethod,
    required this.selectedBankIndex,
    required this.selectedPaymentIndex,
    required this.selectedUsdtIndex,
    required this.selectedEDirhamIndex,
    required this.amount,
    required this.note,
    this.errorMessage,
  });

  factory AccountSummaryState.initial() => const AccountSummaryState(
        selectedMethod: ConvertMethod.transferToBank,
        selectedBankIndex: 0,
        selectedPaymentIndex: 0,
        selectedUsdtIndex: 0,
        selectedEDirhamIndex: 0,
        amount: '',
        note: '',
      );

  AccountSummaryState copyWith({
    ConvertMethod? selectedMethod,
    int? selectedBankIndex,
    int? selectedPaymentIndex,
    int? selectedUsdtIndex,
    int? selectedEDirhamIndex,
    String? amount,
    String? note,
    String? errorMessage,
  }) {
    return AccountSummaryState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      selectedBankIndex: selectedBankIndex ?? this.selectedBankIndex,
      selectedPaymentIndex: selectedPaymentIndex ?? this.selectedPaymentIndex,
      selectedUsdtIndex: selectedUsdtIndex ?? this.selectedUsdtIndex,
      selectedEDirhamIndex: selectedEDirhamIndex ?? this.selectedEDirhamIndex,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      errorMessage: errorMessage,
    );
  }
}
