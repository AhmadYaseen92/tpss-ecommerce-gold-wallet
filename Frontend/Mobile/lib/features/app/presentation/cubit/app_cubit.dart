import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit()
      : super(
          AppState(selectedSeller: AppReleaseConfig.defaultSeller),
        );

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
  }

  void notifyCheckoutCompleted() {
    emit(
      state.copyWith(checkoutRefreshTick: state.checkoutRefreshTick + 1),
    );
  }
}
