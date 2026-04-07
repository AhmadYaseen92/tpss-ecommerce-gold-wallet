// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/data/models/transaction_model.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  String selectedPeriod = 'All Periods';
  String selectedType = 'All Types';
  String selectedStatus = 'All Statuses';
  String activeSeller = AppReleaseConfig.defaultSeller;

  TransactionCubit() : super(TransactionInitial());

  void loadTransactions({String seller = AppReleaseConfig.allSellersLabel}) async {
    activeSeller = AppReleaseConfig.isIndividualSellerRelease
        ? AppReleaseConfig.individualSellerName
        : seller;
    emit(TransactionLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      filteredTransactions = _applyAllFilters();
      emit(TransactionLoaded(transactions: filteredTransactions));
    } catch (e) {
      emit(TransactionError('Failed to load transactions: $e'));
    }
  }

  List<TransactionModel> _applyAllFilters() {
    final now = DateTime.now();
    return dummyTransactions.where((transaction) {
      final difference = now.difference(transaction.date).inDays;

      bool periodMatch = true;
      if (selectedPeriod == 'Last 7 Days') {
        periodMatch = difference <= 7;
      } else if (selectedPeriod == 'Last 30 Days')
        periodMatch = difference <= 30;
      else if (selectedPeriod == 'Last 90 Days')
        periodMatch = difference <= 90;

      bool typeMatch = true;
      if (selectedType == 'Buy') {
        typeMatch = transaction.type.toLowerCase().contains('buy');
      } else if (selectedType == 'Sell')
        typeMatch = transaction.type.toLowerCase().contains('sell');
      else if (selectedType == 'Deposit')
        typeMatch = transaction.type.toLowerCase().contains('deposit');
      else if (selectedType == 'Withdraw')
        typeMatch = transaction.type.toLowerCase().contains('withdraw');

      bool statusMatch = true;
      if (selectedStatus == 'Completed') {
        statusMatch = transaction.status.toLowerCase() == 'completed';
      } else if (selectedStatus == 'Pending')
        statusMatch = transaction.status.toLowerCase() == 'pending';
      else if (selectedStatus == 'Failed')
        statusMatch = transaction.status.toLowerCase() == 'failed';

      final sellerMatch = AppReleaseConfig.matchesSeller(
        activeSeller,
        transaction.sellerName,
      );
      return periodMatch && typeMatch && statusMatch && sellerMatch;
    }).toList();
  }

  void applyFilters(String period, String type, String status) {
    filteredTransactions = _applyAllFilters();
  }

  void onGlobalSellerChanged(String seller) {
    activeSeller = seller;
    filteredTransactions = _applyAllFilters();
    emit(TransactionLoaded(transactions: filteredTransactions));
  }

  void filterByPeriod(String period) {
    selectedPeriod = period;
    applyFilters(selectedPeriod, selectedType, selectedStatus);
    emit(TransactionLoaded(transactions: filteredTransactions));
  }

  void filterByType(String type) {
    selectedType = type;
    applyFilters(selectedPeriod, selectedType, selectedStatus);
    emit(TransactionLoaded(transactions: filteredTransactions));
  }

  void filterByStatus(String status) {
    selectedStatus = status;
    applyFilters(selectedPeriod, selectedType, selectedStatus);
    emit(TransactionLoaded(transactions: filteredTransactions));
  }
}
