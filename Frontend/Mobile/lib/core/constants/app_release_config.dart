class AppReleaseConfig {
  static bool isIndividualSellerRelease = false;
  static String individualSellerName = 'Imseeh';

  static const String defaultAllSellersLabel = 'All Sellers';
  static const String allSellersLabel = defaultAllSellersLabel;

  static bool showWeightInGrams = true;
  static bool loginByBiometricEnabled = true;
  static bool loginByPinEnabled = true;

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
    showWeightInGrams =
        (values['MobileRelease_ShowWeightInGrams'] as bool?) ?? showWeightInGrams;
    loginByBiometricEnabled =
        (values['MobileSecurity_LoginByBiometric'] as bool?) ?? loginByBiometricEnabled;
    loginByPinEnabled =
        (values['MobileSecurity_LoginByPin'] as bool?) ?? loginByPinEnabled;
  }
}
