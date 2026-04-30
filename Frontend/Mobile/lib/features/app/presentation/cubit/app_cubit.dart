import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  static const _themeModeKey = 'app_theme_mode';
  static const _languageCodeKey = 'app_language_code';
  static const _supportedLanguageCodes = {'en', 'ar'};

  AppCubit()
      : super(
          AppState(selectedSeller: AppReleaseConfig.defaultSeller),
        ) {
    _restoreCachedPreferences();
  }

  static List<String> get supportedSellers => AppReleaseConfig.isIndividualSellerRelease
      ? [AppReleaseConfig.individualSellerName]
      : [
          AppReleaseConfig.allSellersLabel,
        ];

  void setSeller(String seller) {
    emit(state.copyWith(selectedSeller: seller));
  }

  void setThemeMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
    _cacheThemeMode(mode);
  }

  void setLocale(Locale? locale) {
    emit(state.copyWith(locale: locale));
    _cacheLanguageCode(locale?.languageCode);
  }

  void notifyCheckoutCompleted() {
    emit(
      state.copyWith(checkoutRefreshTick: state.checkoutRefreshTick + 1),
    );
  }

  Future<void> _restoreCachedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeModeKey);
    final languageCode = prefs.getString(_languageCodeKey);

    ThemeMode restoredThemeMode = ThemeMode.system;
    if (themeName == ThemeMode.light.name) restoredThemeMode = ThemeMode.light;
    if (themeName == ThemeMode.dark.name) restoredThemeMode = ThemeMode.dark;

    Locale? restoredLocale;
    if (languageCode != null && _supportedLanguageCodes.contains(languageCode)) {
      restoredLocale = Locale(languageCode);
    }

    emit(state.copyWith(themeMode: restoredThemeMode, locale: restoredLocale));
  }

  Future<void> _cacheThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<void> _cacheLanguageCode(String? languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == null || !_supportedLanguageCodes.contains(languageCode)) {
      await prefs.remove(_languageCodeKey);
      return;
    }
    await prefs.setString(_languageCodeKey, languageCode);
  }
}
