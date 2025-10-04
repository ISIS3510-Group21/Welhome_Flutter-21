part of 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<HousingPost> recommendedPosts;
  final List<HousingPost> recentlyViewedPosts;

  HomeLoaded({required this.recommendedPosts, required this.recentlyViewedPosts});
}

class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}
