// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/transaction_model.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  String selectedPeriod = 'All Periods';
  String selectedType = 'All Types';
  String selectedStatus = 'All Statuses';

  TransactionCubit() : super(TransactionInitial());

  void loadTransactions() async {
    emit(TransactionLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      filteredTransactions = dummyTransactions;
      emit(TransactionLoaded(transactions: filteredTransactions));
    } catch (e) {
      emit(TransactionError('Failed to load transactions: $e'));
    }
  }

  void applyFilters(String period, String type, String status) {
    final now = DateTime.now();
    filteredTransactions = dummyTransactions.where((transaction) {
      final difference = now.difference(transaction.date).inDays;

      bool periodMatch = true;
      if (period == 'Last 7 Days') {
        periodMatch = difference <= 7;
      } else if (period == 'Last 30 Days')
        periodMatch = difference <= 30;
      else if (period == 'Last 90 Days')
        periodMatch = difference <= 90;

      bool typeMatch = true;
      if (type == 'Buy') {
        typeMatch = transaction.type.toLowerCase().contains('buy');
      } else if (type == 'Sell')
        typeMatch = transaction.type.toLowerCase().contains('sell');
      else if (type == 'Deposit')
        typeMatch = transaction.type.toLowerCase().contains('deposit');
      else if (type == 'Withdraw')
        typeMatch = transaction.type.toLowerCase().contains('withdraw');

      bool statusMatch = true;
      if (status == 'Completed') {
        statusMatch = transaction.status.toLowerCase() == 'completed';
      } else if (status == 'Pending')
        statusMatch = transaction.status.toLowerCase() == 'pending';
      else if (status == 'Failed')
        statusMatch = transaction.status.toLowerCase() == 'failed';

      return periodMatch && typeMatch && statusMatch;
    }).toList();
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
