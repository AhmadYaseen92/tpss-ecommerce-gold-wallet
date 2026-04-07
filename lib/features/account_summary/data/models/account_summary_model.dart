class AccountSummaryModel {
  final String holdMarketValue;
  final String goldValue;
  final String silverValue;
  final String jewelleryValue;
  final String availableCash;
  final String usdtBalance;
  final String eDirhamBalance;

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
