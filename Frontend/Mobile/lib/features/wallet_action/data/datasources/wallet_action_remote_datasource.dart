class WalletActionRemoteDataSource {
  Future<bool> isMarketOpen() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return true;
  }

  Future<double> availableLiquidity() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return 1000000;
  }

  Future<double> lockUnitPrice(double requestedUnitPrice) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return requestedUnitPrice;
  }
}
