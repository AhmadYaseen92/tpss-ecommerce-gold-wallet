class TransferLocalDataSource {
  static const Set<String> _registeredAccounts = {
    '10001',
    '10002',
    '20011',
    '77889',
  };

  Future<bool> isRegisteredAccount(String accountNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _registeredAccounts.contains(accountNumber);
  }
}
