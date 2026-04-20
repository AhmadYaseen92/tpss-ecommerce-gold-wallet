class AppReleaseConfig {
  static bool isIndividualSellerRelease = false;
  static String individualSellerName = 'Imseeh';

  static const String defaultAllSellersLabel = 'All Sellers';
  static String allSellersLabel = defaultAllSellersLabel;

  static bool showWeightInGrams = true;

  static bool get showSellerUi => !isIndividualSellerRelease;

  static String get defaultSeller =>
      isIndividualSellerRelease ? individualSellerName : allSellersLabel;

  static bool matchesSeller(String activeSeller, String itemSeller) {
    if (isIndividualSellerRelease) {
      return itemSeller == individualSellerName;
    }
    return activeSeller == allSellersLabel || itemSeller == activeSeller;
  }

  static void applyFromTypedConfig(Map<String, dynamic> values) {
    isIndividualSellerRelease =
        (values['MobileRelease_IsIndividualSeller'] as bool?) ?? isIndividualSellerRelease;
    individualSellerName =
        (values['MobileRelease_IndividualSellerName'] as String?) ?? individualSellerName;
    allSellersLabel =
        (values['MobileRelease_AllSellersLabel'] as String?) ?? allSellersLabel;
    showWeightInGrams =
        (values['MobileRelease_ShowWeightInGrams'] as bool?) ?? showWeightInGrams;
  }
}
