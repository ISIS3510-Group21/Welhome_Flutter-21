abstract class StudentUserProfileRepository {

  Future<List<String>> getVisitedHousingIds(String userId);

  Future<List<String>> getRecommendedHousingIds(String userId);
}