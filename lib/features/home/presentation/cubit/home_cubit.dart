import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:welhome/features/home/domain/usecases/get_recommended_posts.dart';
import 'package:welhome/features/home/domain/usecases/get_recently_viewed_posts.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetRecommendedPosts getRecommendedPosts;
  final GetRecentlyViewedPosts getRecentlyViewedPosts;
  final String userId;

  HomeCubit({
    required this.getRecommendedPosts,
    required this.getRecentlyViewedPosts,
    required this.userId,
  }) : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());

    try {
      final recommended = await getRecommendedPosts();
      final visited = await getRecentlyViewedPosts(userId: userId);

      emit(HomeLoaded(
        recommendedPosts: recommended,
        recentlyViewedPosts: visited,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
