import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/data/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/features/convert/data/models/account_conversion_request_model.dart';

part 'account_summary_state.dart';

class AccountSummaryCubit extends Cubit<AccountSummaryState> {
  AccountSummaryCubit() : super(AccountSummaryFormState.initial());

  static const double totalPortfolio = 12450.0;
  static const double usdToEDirhamRate = 3.6725;

  AccountSummaryFormState get _formState {
    if (state is AccountSummaryFormState) {
      return state as AccountSummaryFormState;
    }
    return AccountSummaryFormState.initial();
  }

  void setMethod(ConvertMethod method) {
    final current = _formState;
    emit(
      AccountSummaryFormState(
        selectedMethod: method,
        selectedBankIndex: current.selectedBankIndex,
        selectedPaymentIndex: current.selectedPaymentIndex,
        selectedUsdtIndex: current.selectedUsdtIndex,
        selectedEDirhamIndex: current.selectedEDirhamIndex,
        amount: current.amount,
        note: current.note,
      ),
    );
  }

  void setBankIndex(int index) {
    final current = _formState;
    emit(
      AccountSummaryFormState(
        selectedMethod: current.selectedMethod,
        selectedBankIndex: index,
        selectedPaymentIndex: current.selectedPaymentIndex,
        selectedUsdtIndex: current.selectedUsdtIndex,
        selectedEDirhamIndex: current.selectedEDirhamIndex,
        amount: current.amount,
        note: current.note,
      ),
    );
  }

  void setPaymentIndex(int index) {
    final current = _formState;
    emit(
      AccountSummaryFormState(
        selectedMethod: current.selectedMethod,
        selectedBankIndex: current.selectedBankIndex,
        selectedPaymentIndex: index,
        selectedUsdtIndex: current.selectedUsdtIndex,
        selectedEDirhamIndex: current.selectedEDirhamIndex,
        amount: current.amount,
        note: current.note,
      ),
    );
  }

  void setUsdtIndex(int index) {
    final current = _formState;
    emit(
      AccountSummaryFormState(
        selectedMethod: current.selectedMethod,
        selectedBankIndex: current.selectedBankIndex,
        selectedPaymentIndex: current.selectedPaymentIndex,
        selectedUsdtIndex: index,
        selectedEDirhamIndex: current.selectedEDirhamIndex,
        amount: current.amount,
        note: current.note,
      ),
    );
  }

  void setEDirhamIndex(int index) {
    final current = _formState;
    emit(
      AccountSummaryFormState(
        selectedMethod: current.selectedMethod,
        selectedBankIndex: current.selectedBankIndex,
        selectedPaymentIndex: current.selectedPaymentIndex,
        selectedUsdtIndex: current.selectedUsdtIndex,
        selectedEDirhamIndex: index,
        amount: current.amount,
        note: current.note,
      ),
    );
  }

  void setAmount(String value) {
    final current = _formState;
    emit(
      AccountSummaryFormState(
        selectedMethod: current.selectedMethod,
        selectedBankIndex: current.selectedBankIndex,
        selectedPaymentIndex: current.selectedPaymentIndex,
        selectedUsdtIndex: current.selectedUsdtIndex,
        selectedEDirhamIndex: current.selectedEDirhamIndex,
        amount: value,
        note: current.note,
      ),
    );
  }

  void setNote(String value) {
    final current = _formState;
    emit(
      AccountSummaryFormState(
        selectedMethod: current.selectedMethod,
        selectedBankIndex: current.selectedBankIndex,
        selectedPaymentIndex: current.selectedPaymentIndex,
        selectedUsdtIndex: current.selectedUsdtIndex,
        selectedEDirhamIndex: current.selectedEDirhamIndex,
        amount: current.amount,
        note: value,
      ),
    );
  }

  String get methodLabel {
    final current = _formState;
    switch (current.selectedMethod) {
      case ConvertMethod.transferToBank:
        return 'Transfer To Bank Account';
      case ConvertMethod.transferToCard:
        return 'Transfer To Card Account';
      case ConvertMethod.transferToUsdt:
        return 'Transfer To USDT Account';
      case ConvertMethod.transferToEDirham:
        return 'Transfer To E-Dirham Account';
    }
  }

  String get targetAccount {
    final current = _formState;
    switch (current.selectedMethod) {
      case ConvertMethod.transferToBank:
        return PredefinedAccountsData.bankAccounts[current.selectedBankIndex].name;
      case ConvertMethod.transferToCard:
        return PredefinedAccountsData.paymentMethods[current.selectedPaymentIndex].name;
      case ConvertMethod.transferToUsdt:
        return PredefinedAccountsData.usdtAccounts[current.selectedUsdtIndex].name;
      case ConvertMethod.transferToEDirham:
        return PredefinedAccountsData.eDirhamAccounts[current.selectedEDirhamIndex].name;
    }
  }

  AccountConversionRequest? buildRequest() {
    final current = _formState;
    final amount = double.tryParse(current.amount.trim());
    if (amount == null || amount <= 0) {
      _emitWithError('Enter a valid amount.');
      return null;
    }
    if (amount > totalPortfolio) {
      _emitWithError('Amount must be <= total portfolio.');
      return null;
    }

    return AccountConversionRequest(
      method: current.selectedMethod,
      targetAccount: targetAccount,
      amount: amount,
      note: current.note.trim(),
    );
  }

  void _emitWithError(String message) {
    final current = _formState;
    emit(
      AccountSummaryFormState(
        selectedMethod: current.selectedMethod,
        selectedBankIndex: current.selectedBankIndex,
        selectedPaymentIndex: current.selectedPaymentIndex,
        selectedUsdtIndex: current.selectedUsdtIndex,
        selectedEDirhamIndex: current.selectedEDirhamIndex,
        amount: current.amount,
        note: current.note,
        errorMessage: message,
      ),
    );
  }

  String? convertedAmountLabel(AccountSummaryFormState state) {
    final amount = double.tryParse(state.amount.trim());
    if (amount == null || amount <= 0) return null;

    switch (state.selectedMethod) {
      case ConvertMethod.transferToUsdt:
        return '${NumberFormat('#,##0.##').format(amount)} USDT';
      case ConvertMethod.transferToEDirham:
        return 'AED ${NumberFormat('#,##0.00').format(amount * usdToEDirhamRate)}';
      case ConvertMethod.transferToBank:
      case ConvertMethod.transferToCard:
        return null;
    }
  }
}
