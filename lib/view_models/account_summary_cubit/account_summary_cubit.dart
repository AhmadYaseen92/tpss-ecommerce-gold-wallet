import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/data/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_conversion_request_model.dart';

part 'account_summary_state.dart';

class AccountSummaryCubit extends Cubit<AccountSummaryState> {
  AccountSummaryCubit() : super(AccountSummaryState.initial());

  static const double totalPortfolio = 12450.0;

  void setMethod(ConvertMethod method) {
    emit(state.copyWith(selectedMethod: method, errorMessage: null));
  }

  void setBankIndex(int index) => emit(state.copyWith(selectedBankIndex: index, errorMessage: null));
  void setPaymentIndex(int index) => emit(state.copyWith(selectedPaymentIndex: index, errorMessage: null));
  void setUsdtIndex(int index) => emit(state.copyWith(selectedUsdtIndex: index, errorMessage: null));
  void setEDirhamIndex(int index) => emit(state.copyWith(selectedEDirhamIndex: index, errorMessage: null));
  void setAmount(String value) => emit(state.copyWith(amount: value, errorMessage: null));
  void setNote(String value) => emit(state.copyWith(note: value, errorMessage: null));

  String get methodLabel {
    switch (state.selectedMethod) {
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
    switch (state.selectedMethod) {
      case ConvertMethod.transferToBank:
        return PredefinedAccountsData.bankAccounts[state.selectedBankIndex].name;
      case ConvertMethod.transferToCard:
        return PredefinedAccountsData.paymentMethods[state.selectedPaymentIndex].name;
      case ConvertMethod.transferToUsdt:
        return PredefinedAccountsData.usdtAccounts[state.selectedUsdtIndex].name;
      case ConvertMethod.transferToEDirham:
        return PredefinedAccountsData.eDirhamAccounts[state.selectedEDirhamIndex].name;
    }
  }

  AccountConversionRequest? buildRequest() {
    final amount = double.tryParse(state.amount.trim());
    if (amount == null || amount <= 0) {
      emit(state.copyWith(errorMessage: 'Enter a valid amount.'));
      return null;
    }
    if (amount > totalPortfolio) {
      emit(state.copyWith(errorMessage: 'Amount must be <= total portfolio.'));
      return null;
    }

    return AccountConversionRequest(
      method: state.selectedMethod,
      targetAccount: targetAccount,
      amount: amount,
      note: state.note.trim(),
    );
  }
}
