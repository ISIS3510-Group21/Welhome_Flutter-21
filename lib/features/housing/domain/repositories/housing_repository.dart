import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_with_distance_entity.dart';

abstract class HousingRepository {

  Future<List<HousingPostEntity>> getRecommendedPosts({
    required String userId,
  });

  Future<List<HousingPostEntity>> getRecentlyViewedPosts({
    required String userId,
  });

  Future<HousingPostEntity?> getPostDetails({
    required String postId,
  });

  Future<List<HousingPostEntity>> findPostsNearLocation({
    required double lat,
    required double lng,
    required double radiusInKm,
  });

  Future<List<HousingPostEntity>> getAllHousingPosts();

  Future<List<HousingPostEntity>> getAllAvailableHousingPosts();

  Future<List<HousingPostWithDistanceEntity>> getHousingPostsWithDistance(
    double userLat, 
    double userLng,
  );
}

