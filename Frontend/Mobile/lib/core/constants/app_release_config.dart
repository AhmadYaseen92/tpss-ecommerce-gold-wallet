class AppReleaseConfig {
  /// Key used by backend MobileAppConfigurations to sync release setup with mobile.
  static const String configKey = 'mobile.release-config';

  /// Set to true when this build is dedicated to one seller only.
  static bool isIndividualSellerRelease = false;

  /// Used only when [isIndividualSellerRelease] is true.
  static String individualSellerName = 'Imseeh';

  static const String defaultAllSellersLabel = 'All Sellers';
  static String allSellersLabel = defaultAllSellersLabel;

  /// Feature flag for displaying calculated gram labels in UI.
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

  static void applyFromJson(Map<String, dynamic> json) {
    isIndividualSellerRelease =
        (json['isIndividualSellerRelease'] as bool?) ?? isIndividualSellerRelease;
    individualSellerName =
        (json['individualSellerName'] as String?) ?? individualSellerName;
    allSellersLabel = (json['allSellersLabel'] as String?) ?? allSellersLabel;
    showWeightInGrams = (json['showWeightInGrams'] as bool?) ?? showWeightInGrams;
  }
}
