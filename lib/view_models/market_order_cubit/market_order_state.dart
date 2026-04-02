part of 'market_order_cubit.dart';

sealed class MarketOrderState {}

class MarketOrderInitial extends MarketOrderState {}

class MarketOrderLoading extends MarketOrderState {}

class MarketOrderLoaded extends MarketOrderState {
  final List<MarketOrderModel> orders;
  final String sellerFilter;
  final MarketOrderStatusFilter statusFilter;

  MarketOrderLoaded({
    required this.orders,
    required this.sellerFilter,
    required this.statusFilter,
  });
}

class MarketOrderError extends MarketOrderState {
  final String message;
  MarketOrderError(this.message);
}
