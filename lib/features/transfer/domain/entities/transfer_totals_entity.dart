class TransferTotalsEntity {
  const TransferTotalsEntity({
    required this.subtotal,
    required this.fee,
    required this.totalDeducted,
  });

  final double subtotal;
  final double fee;
  final double totalDeducted;
}
