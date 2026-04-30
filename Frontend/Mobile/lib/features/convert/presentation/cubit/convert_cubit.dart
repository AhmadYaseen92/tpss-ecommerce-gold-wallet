import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/api_error_parser.dart';

part 'convert_state.dart';

class ConvertCubit extends Cubit<ConvertState> {
  double amount = 0.0;
  bool agreedToTerms = false;
  String fromCurrency = 'USDT';

  static const double usdtToUsdRate = 1.0;

  ConvertCubit() : super(ConvertInitial());

  String get toCurrency => fromCurrency == 'USDT' ? 'USD' : 'USDT';
  double get subtotal => amount * usdtToUsdRate;
  double get fee => subtotal * ConvertState.feePercent;
  double get receive => subtotal - fee;

  void updateAmount(String value) {
    amount = double.tryParse(value) ?? 0.0;
    emit(ConvertDataChanged(
      amount: amount,
      agreedToTerms: agreedToTerms,
      fromCurrency: fromCurrency,
    ));
  }

  void toggleTerms(bool? value) {
    agreedToTerms = value ?? false;
    emit(ConvertDataChanged(
      amount: amount,
      agreedToTerms: agreedToTerms,
      fromCurrency: fromCurrency,
    ));
  }

  void selectFromCurrency(String currency) {
    fromCurrency = currency;
    amount = 0.0;
    emit(ConvertDataChanged(
      amount: amount,
      agreedToTerms: agreedToTerms,
      fromCurrency: fromCurrency,
    ));
  }

  void loadConvertData() async {
    emit(ConvertLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      emit(ConvertDataChanged(
        amount: amount,
        agreedToTerms: agreedToTerms,
        fromCurrency: fromCurrency,
      ));
    } catch (e) {
      emit(ConvertError('Failed to load convert data: ${ApiErrorParser.friendlyFromAny(e)}'));
    }
  }

    IconData currencyIcon(String currency) {
    return currency == 'USDT'
        ? Icons.monetization_on_outlined
        : Icons.attach_money_rounded;
  }


}
