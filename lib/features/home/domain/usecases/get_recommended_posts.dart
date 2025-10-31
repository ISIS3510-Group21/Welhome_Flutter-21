import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/housing/domain/repositories/housing_repository.dart';

class GetRecommendedPosts {
  final HousingRepository repository;

  GetRecommendedPosts(this.repository);

  Future<List<HousingPostEntity>> call() async {
    return await repository.getRecommendedPosts();
  }
}