import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/housing/domain/repositories/housing_repository.dart';

class GetRecentlyViewedPosts {
  final HousingRepository repository;

  GetRecentlyViewedPosts(this.repository);

  Future<List<HousingPostEntity>> call({required String userId}) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    return await repository.getRecentlyViewedPosts(userId: userId);
  }
}