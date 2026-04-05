abstract class WalletActionRepository {
  Future<bool> isMarketOpen();

  Future<double> availableLiquidity();

  Future<double> lockUnitPrice(double requestedUnitPrice);
}
