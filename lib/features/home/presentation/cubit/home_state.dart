part of 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<HousingPostEntity> recommendedPosts;
  final List<HousingPostEntity> recentlyViewedPosts;

  HomeLoaded({required this.recommendedPosts, required this.recentlyViewedPosts});
}

class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}
