import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/domain/entities/market_order_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/domain/repositories/market_order_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/domain/usecases/get_filtered_market_orders.dart';

part 'market_order_state.dart';

class MarketOrderCubit extends Cubit<MarketOrderState> {
  MarketOrderCubit({
    required IMarketOrderRepository repository,
    Duration refreshInterval = const Duration(seconds: 1),
  }) : _repository = repository,
       _getFilteredMarketOrders = GetFilteredMarketOrders(repository),
       _refreshInterval = refreshInterval,
       super(MarketOrderInitial());

  final IMarketOrderRepository _repository;
  final GetFilteredMarketOrders _getFilteredMarketOrders;
  final Duration _refreshInterval;

  Timer? _refreshTimer;
  String _sellerFilter = AppReleaseConfig.allSellersLabel;
  MarketOrderStatusFilter _statusFilter = MarketOrderStatusFilter.all;

  void load({String sellerFilter = AppReleaseConfig.allSellersLabel}) {
    _sellerFilter = sellerFilter;
    emit(MarketOrderLoading());
    _emitFiltered();
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => _emitFiltered());
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

  void cancelOrder(String orderId) {
    _repository.cancelOrder(orderId);
    _emitFiltered();
  }

  double livePriceForSymbol(String symbol, {double fallback = 0}) {
    return _repository.livePriceForSymbol(symbol, fallback: fallback);
  }

  void _emitFiltered() {
    try {
      final orders = _getFilteredMarketOrders(
        sellerFilter: _sellerFilter,
        statusFilter: _statusFilter,
      );

      emit(
        MarketOrderLoaded(
          orders: orders,
          sellerFilter: _sellerFilter,
          statusFilter: _statusFilter,
        ),
      );
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
