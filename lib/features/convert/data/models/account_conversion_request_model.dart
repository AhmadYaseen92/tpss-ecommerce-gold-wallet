enum ConvertMethod {
  transferToBank,
  transferToCard,
  transferToUsdt,
  transferToEDirham,
}

class AccountConversionRequest {
  final ConvertMethod method;
  final String targetAccount;
  final double amount;
  final String note;

  const AccountConversionRequest({
    required this.method,
    required this.targetAccount,
    required this.amount,
    this.note = '',
  });
}
