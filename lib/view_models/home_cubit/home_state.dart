part of 'home_cubit.dart';

class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final int currentIndex;

  HomeLoaded({required this.currentIndex});
}

final class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});
}
