import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  void getHomeData() {
    emit(HomeLoading());
    try {
      // Simulate data fetching
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(HomeLoaded(currentIndex: 0));
      });
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
