part of 'market_order_cubit.dart';

sealed class MarketOrderState {}

class MarketOrderInitial extends MarketOrderState {}

class MarketOrderLoading extends MarketOrderState {}

class MarketOrderLoaded extends MarketOrderState {
  MarketOrderLoaded({
    required this.orders,
    required this.sellerFilter,
    required this.statusFilter,
  });

  final List<MarketOrderEntity> orders;
  final String sellerFilter;
  final MarketOrderStatusFilter statusFilter;
}

class MarketOrderError extends MarketOrderState {
  MarketOrderError(this.message);

  final String message;
}
