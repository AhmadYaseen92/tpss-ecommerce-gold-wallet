part of 'onboarding_cubit.dart';

class OnboardingState {}

final class OnboardingInitial extends OnboardingState {}

final class OnboardingLoading extends OnboardingState {}

final class OnboardingLoaded extends OnboardingState {
  final int currentPage;

  OnboardingLoaded({required this.currentPage});
}

final class OnboardingError extends OnboardingState {
  final String message;

  OnboardingError({required this.message});
}

final class OnboardingPageChanged extends OnboardingState {
  final int page;

  OnboardingPageChanged({required this.page});
}
