import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/housing/domain/repositories/housing_repository.dart';

class GetRecommendedPosts {
  final HousingRepository repository;

  GetRecommendedPosts(this.repository);

  Future<List<HousingPostEntity>> call({required String userId}) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    return await repository.getRecommendedPosts(userId: userId);
  }
}