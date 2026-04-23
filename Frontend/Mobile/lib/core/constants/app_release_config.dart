class AppReleaseConfig {
  static final Map<String, dynamic> _allTypedConfig = <String, dynamic>{};

  static bool isIndividualSellerRelease = false;
  static String individualSellerName = 'Imseeh';

  static const String defaultAllSellersLabel = 'All Sellers';
  static const String allSellersLabel = defaultAllSellersLabel;

  static bool showWeightInGrams = true;
  static bool marketWatchEnabled = true;
  static bool loginByBiometricEnabled = true;
  static bool loginByPinEnabled = true;
  static bool get quickUnlockAllowed => loginByBiometricEnabled || loginByPinEnabled;

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
    _allTypedConfig
      ..clear()
      ..addAll(values);

    isIndividualSellerRelease =
        (values['MobileRelease_IsIndividualSeller'] as bool?) ?? isIndividualSellerRelease;
    individualSellerName =
        (values['MobileRelease_IndividualSellerName'] as String?) ?? individualSellerName;
    showWeightInGrams =
        (values['MobileRelease_ShowWeightInGrams'] as bool?) ?? showWeightInGrams;
    marketWatchEnabled =
        (values['MobileRelease_MarketWatchEnabled'] as bool?) ?? marketWatchEnabled;
    loginByBiometricEnabled =
        (values['MobileSecurity_LoginByBiometric'] as bool?) ?? loginByBiometricEnabled;
    loginByPinEnabled =
        (values['MobileSecurity_LoginByPin'] as bool?) ?? loginByPinEnabled;
  }

  static dynamic getValue(String key) => _allTypedConfig[key];
}
