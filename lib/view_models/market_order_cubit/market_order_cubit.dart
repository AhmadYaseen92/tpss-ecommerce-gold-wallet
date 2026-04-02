import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/data/market_order_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/models/market_order_model.dart';

part 'market_order_state.dart';

enum MarketOrderStatusFilter { all, pending, filled, rejected, cancelled }

class MarketOrderCubit extends Cubit<MarketOrderState> {
  MarketOrderCubit() : super(MarketOrderInitial());

  Timer? _refreshTimer;
  String _sellerFilter = AppReleaseConfig.allSellersLabel;
  MarketOrderStatusFilter _statusFilter = MarketOrderStatusFilter.all;

  void load({String sellerFilter = AppReleaseConfig.allSellersLabel}) {
    _sellerFilter = sellerFilter;
    emit(MarketOrderLoading());
    _emitFiltered();
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) => _emitFiltered());
  }

  void setSellerFilter(String seller) {
    if (_sellerFilter == seller) return;
    _sellerFilter = seller;
    _emitFiltered();
  }

  void setStatusFilter(MarketOrderStatusFilter filter) {
    if (_statusFilter == filter) return;
    _statusFilter = filter;
    _emitFiltered();
  }

  void _emitFiltered() {
    try {
      final orders = MarketOrderRepository.orders.where((order) {
        final sellerMatch = AppReleaseConfig.matchesSeller(_sellerFilter, order.seller);
        final statusMatch = switch (_statusFilter) {
          MarketOrderStatusFilter.all => true,
          MarketOrderStatusFilter.pending => order.status == MarketOrderStatus.pending,
          MarketOrderStatusFilter.filled => order.status == MarketOrderStatus.filled,
          MarketOrderStatusFilter.rejected => order.status == MarketOrderStatus.rejected,
          MarketOrderStatusFilter.cancelled => order.status == MarketOrderStatus.cancelled,
        };
        return sellerMatch && statusMatch;
      }).toList();

      emit(MarketOrderLoaded(
        orders: orders,
        sellerFilter: _sellerFilter,
        statusFilter: _statusFilter,
      ));
    } catch (e) {
      emit(MarketOrderError('Failed to load market orders: $e'));
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
