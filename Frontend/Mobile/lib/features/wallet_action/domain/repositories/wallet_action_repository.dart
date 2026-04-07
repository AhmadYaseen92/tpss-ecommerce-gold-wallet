abstract class IWalletActionRepository {
  Future<bool> isMarketOpen();

  Future<double> availableLiquidity();

  Future<double> lockUnitPrice(double requestedUnitPrice);
}
