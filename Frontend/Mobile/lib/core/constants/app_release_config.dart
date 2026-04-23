import 'package:flutter/foundation.dart';

class AppReleaseConfig {
  static final Map<String, dynamic> _allTypedConfig = <String, dynamic>{};
  static final ValueNotifier<int> revisionListenable = ValueNotifier<int>(0);

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
    final nextIndividualSellerRelease =
        (values['MobileRelease_IsIndividualSeller'] as bool?) ?? isIndividualSellerRelease;
    final nextIndividualSellerName =
        (values['MobileRelease_IndividualSellerName'] as String?) ?? individualSellerName;
    final nextShowWeightInGrams =
        (values['MobileRelease_ShowWeightInGrams'] as bool?) ?? showWeightInGrams;
    final nextMarketWatchEnabled =
        (values['MobileRelease_MarketWatchEnabled'] as bool?) ?? marketWatchEnabled;
    final nextLoginByBiometricEnabled =
        (values['MobileSecurity_LoginByBiometric'] as bool?) ?? loginByBiometricEnabled;
    final nextLoginByPinEnabled =
        (values['MobileSecurity_LoginByPin'] as bool?) ?? loginByPinEnabled;

    final hasChanged = nextIndividualSellerRelease != isIndividualSellerRelease ||
        nextIndividualSellerName != individualSellerName ||
        nextShowWeightInGrams != showWeightInGrams ||
        nextMarketWatchEnabled != marketWatchEnabled ||
        nextLoginByBiometricEnabled != loginByBiometricEnabled ||
        nextLoginByPinEnabled != loginByPinEnabled;

    _allTypedConfig
      ..clear()
      ..addAll(values);

    isIndividualSellerRelease = nextIndividualSellerRelease;
    individualSellerName = nextIndividualSellerName;
    showWeightInGrams = nextShowWeightInGrams;
    marketWatchEnabled = nextMarketWatchEnabled;
    loginByBiometricEnabled = nextLoginByBiometricEnabled;
    loginByPinEnabled = nextLoginByPinEnabled;

    if (hasChanged) {
      revisionListenable.value = revisionListenable.value + 1;
    }
  }

  static dynamic getValue(String key) => _allTypedConfig[key];
}
