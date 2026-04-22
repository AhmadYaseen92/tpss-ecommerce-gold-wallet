class ActionSummaryModel {
  const ActionSummaryModel({
    required this.subTotalAmount,
    required this.totalFeesAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.currency,
    required this.feeBreakdowns,
  });

  final double subTotalAmount;
  final double totalFeesAmount;
  final double discountAmount;
  final double finalAmount;
  final String currency;
  final List<ActionSummaryFeeBreakdownRow> feeBreakdowns;

  static const zero = ActionSummaryModel(
    subTotalAmount: 0,
    totalFeesAmount: 0,
    discountAmount: 0,
    finalAmount: 0,
    currency: 'USD',
    feeBreakdowns: [],
  );
}

class ActionSummaryFeeBreakdownRow {
  const ActionSummaryFeeBreakdownRow({
    required this.feeName,
    required this.appliedValue,
    required this.isDiscount,
  });

  final String feeName;
  final double appliedValue;
  final bool isDiscount;
}
