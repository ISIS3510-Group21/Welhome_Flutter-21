import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:welhome/core/data/models/housing_post.dart';
import 'package:welhome/core/data/services/student_user_profile_housing_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final StudentUserProfileHousingService housingService;
  final String userId;

  HomeCubit({required this.housingService, required this.userId})
      : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());

    try {
      final recommended =
          await housingService.getHousingPosts(userId, HousingQueryType.recommended);
      final visited =
          await housingService.getHousingPosts(userId, HousingQueryType.visited);

      emit(HomeLoaded(
        recommendedPosts: recommended,
        recentlyViewedPosts: visited,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
