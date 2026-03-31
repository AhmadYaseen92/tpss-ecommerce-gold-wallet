class AccountSummaryModel {
  final double holdMarketValue;
  final double goldValue;
  final double silverValue;
  final double jewelleryValue;
  final double availableCash;
  final double usdtBalance;
  final double eDirhamBalance;

  const AccountSummaryModel({
    required this.holdMarketValue,
    required this.goldValue,
    required this.silverValue,
    required this.jewelleryValue,
    required this.availableCash,
    required this.usdtBalance,
    required this.eDirhamBalance,
  });
}
