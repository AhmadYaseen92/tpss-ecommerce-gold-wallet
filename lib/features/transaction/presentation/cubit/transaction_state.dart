part of 'transaction_cubit.dart';

class TransactionState {}

final class TransactionInitial extends TransactionState {}

final class TransactionLoading extends TransactionState {}

final class TransactionLoaded extends TransactionState {
  List<TransactionModel> transactions;

  TransactionLoaded({required this.transactions});
}

final class TransactionError extends TransactionState {
  final String message;

  TransactionError(this.message);
}
