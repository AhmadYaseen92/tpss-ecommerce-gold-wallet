class AppReleaseConfig {
  /// Set to true when this build is dedicated to one seller only.
  static const bool isIndividualSellerRelease = false;

  /// Used only when [isIndividualSellerRelease] is true.
  static const String individualSellerName = 'Imseeh';

  static const String allSellersLabel = 'All Sellers';

  static bool get showSellerUi => !isIndividualSellerRelease;

  static String get defaultSeller =>
      isIndividualSellerRelease ? individualSellerName : allSellersLabel;

  static bool matchesSeller(String activeSeller, String itemSeller) {
    if (isIndividualSellerRelease) {
      return itemSeller == individualSellerName;
    }
    return activeSeller == allSellersLabel || itemSeller == activeSeller;
  }
}
