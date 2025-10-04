import 'package:welhome/core/data/models/housing_post.dart';
import 'package:welhome/core/data/repositories/housing_repository.dart';
import 'package:welhome/core/data/repositories/student_user_profile_repository.dart';

enum HousingQueryType { visited, recommended }

class StudentUserProfileHousingService {
  final StudentUserProfileRepository studentUserProfileRepo;
  final HousingRepository housingRepo;

  StudentUserProfileHousingService({
    required this.studentUserProfileRepo,
    required this.housingRepo,
  });

  Future<List<HousingPost>> getHousingPosts(String userId, HousingQueryType type) async {
    List<String> housingIds;

    switch (type) {
      case HousingQueryType.visited:
        housingIds = await studentUserProfileRepo.getVisitedHousingIds(userId);
        break;
      case HousingQueryType.recommended:
        housingIds = await studentUserProfileRepo.getRecommendedHousingIds(userId);
        break;
    }

    final housingPosts = await Future.wait(
      housingIds.map((id) => housingRepo.getHousingPostById(id)),
    );

    return housingPosts.whereType<HousingPost>().toList();
  }
}
