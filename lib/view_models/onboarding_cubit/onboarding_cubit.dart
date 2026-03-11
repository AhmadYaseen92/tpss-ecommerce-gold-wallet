import 'package:bloc/bloc.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingInitial());
  int currentPage = 1;

  void loadOnboarding() {
    emit(OnboardingLoading());
    Future.delayed(const Duration(seconds: 0), () {
      emit(OnboardingLoaded(currentPage: currentPage));
    });
  }

  void goToStep1() {
    currentPage = 1;
    emit(OnboardingPageChanged(page: 1));
  }

  void goToStep2() {
    currentPage = 2;
    emit(OnboardingPageChanged(page: 2));
  }

  void goToStep3() {
    currentPage = 3;
    emit(OnboardingPageChanged(page: 3));
  }

  void updateCurrentPage(int page) {
    emit(OnboardingLoaded(currentPage: page));
  }
}
