// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/product_category_filter.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/dio_factory.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/data/models/transaction_model.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  String selectedPeriod = 'All Periods';
  String selectedType = 'All Types';
  String selectedStatus = 'All Statuses';
  String searchQuery = '';
  int? selectedCategoryId;
  String activeSeller = AppReleaseConfig.defaultSeller;

  final Dio _dio = DioFactory.create();
  List<TransactionModel> _allTransactions = [];
  StreamSubscription<String>? _realtimeSubscription;
  bool _isLoading = false;

  TransactionCubit() : super(TransactionInitial()) {
    unawaited(_startRealtimeRefresh());
  }

  Future<void> _startRealtimeRefresh() async {
    await InjectionContainer.realtimeRefreshService().ensureStarted();
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = InjectionContainer.realtimeRefreshService().refreshes.listen((_) {
      if (AuthSessionStore.userId != null && !_isLoading) {
        unawaited(loadTransactions(seller: activeSeller, silent: true));
      }
    });
  }

  Future<void> loadTransactions({
    String seller = AppReleaseConfig.allSellersLabel,
    bool silent = false,
  }) async {
    if (_isLoading) return;
    activeSeller = AppReleaseConfig.isIndividualSellerRelease
        ? AppReleaseConfig.individualSellerName
        : seller;

    final userId = AuthSessionStore.userId;
    if (userId == null) {
      emit(TransactionError('No logged in user found. Please login again.'));
      return;
    }

    if (!silent) {
      emit(TransactionLoading());
    }
    _isLoading = true;
    try {
      final response = await _dio.post(
        '/transaction-history/filter',
        data: {
          'userId': userId,
          'pageNumber': 1,
          'pageSize': 200,
        },
      );

      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>?;
      final items = (data?['items'] as List<dynamic>? ?? []);

      _allTransactions = items
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList();

      emit(TransactionLoaded(transactions: _applyAllFilters()));
    } catch (e) {
      emit(TransactionError('Failed to load transactions: $e'));
    } finally {
      _isLoading = false;
    }
  }

  List<TransactionModel> _applyAllFilters() {
    final now = DateTime.now().toUtc();
    return _allTransactions.where((transaction) {
      final difference = now.difference(transaction.displayDate.toUtc()).inDays;

      bool periodMatch = true;
      if (selectedPeriod == 'Last 7 Days') {
        periodMatch = difference <= 7;
      } else if (selectedPeriod == 'Last 30 Days')
        periodMatch = difference <= 30;
      else if (selectedPeriod == 'Last 90 Days')
        periodMatch = difference <= 90;

      bool typeMatch = true;
      if (selectedType != 'All Types') {
        typeMatch = transaction.transactionType.toLowerCase() ==
            selectedType.toLowerCase();
      }

      bool statusMatch = true;
      if (selectedStatus != 'All Statuses') {
        statusMatch = transaction.status.toLowerCase() ==
            selectedStatus.toLowerCase();
      }

      final categoryMatch = selectedCategoryId == null ||
          ProductCategoryFilter.inferCategoryId(
                name: transaction.category,
                description: transaction.transactionType,
              ) ==
              selectedCategoryId;

      final searchable = '${transaction.productName} ${transaction.category} ${transaction.transactionType} ${transaction.notes}'.toLowerCase();
      final searchMatch = searchQuery.trim().isEmpty || searchable.contains(searchQuery.trim().toLowerCase());

      return periodMatch && typeMatch && statusMatch && categoryMatch && searchMatch;
    }).toList();
  }

  void applyFilters(String period, String type, String status) {
    emit(TransactionLoaded(transactions: _applyAllFilters()));
  }

  void onGlobalSellerChanged(String seller) {
    activeSeller = seller;
    emit(TransactionLoaded(transactions: _applyAllFilters()));
  }

  void filterByPeriod(String period) {
    selectedPeriod = period;
    applyFilters(selectedPeriod, selectedType, selectedStatus);
  }

  void filterByType(String type) {
    selectedType = type;
    applyFilters(selectedPeriod, selectedType, selectedStatus);
  }

  void filterByStatus(String status) {
    selectedStatus = status;
    applyFilters(selectedPeriod, selectedType, selectedStatus);
  }

  void filterByCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    applyFilters(selectedPeriod, selectedType, selectedStatus);
  }

  void filterBySearch(String value) {
    searchQuery = value;
    applyFilters(selectedPeriod, selectedType, selectedStatus);
  }

  @override
  Future<void> close() async {
    await _realtimeSubscription?.cancel();
    return super.close();
  }
}
