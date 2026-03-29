import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState(selectedSeller: 'All Sellers'));

  static const List<String> supportedSellers = [
    'All Sellers',
    'Imseeh',
    'Sakkejha',
    'Da’naa',
  ];

  void setSeller(String seller) {
    if (!supportedSellers.contains(seller)) return;
    emit(state.copyWith(selectedSeller: seller));
  }
}
