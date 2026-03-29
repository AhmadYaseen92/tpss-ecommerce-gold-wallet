enum ConvertMethod {
  cashSettlement,
  toUsdt,
  toEDirham,
}

class AccountConversionRequest {
  final ConvertMethod method;
  final String? bankAccount;
  final String? paymentMethod;
  final String? targetWallet;
  final double bankAmount;
  final double cardAmount;
  final double convertAmount;
  final String note;

  const AccountConversionRequest({
    required this.method,
    this.bankAccount,
    this.paymentMethod,
    this.targetWallet,
    this.bankAmount = 0,
    this.cardAmount = 0,
    this.convertAmount = 0,
    this.note = '',
  });

  double get total => method == ConvertMethod.cashSettlement ? bankAmount + cardAmount : convertAmount;
}
