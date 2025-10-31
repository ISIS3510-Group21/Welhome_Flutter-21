import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/housing/data/models/housing_post_model.dart';
import 'package:welhome/features/housing/data/models/reviews_model.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/housing/domain/repositories/housing_repository.dart';
import 'package:welhome/features/housing/domain/repositories/reviews_repository.dart';
import 'package:welhome/features/housing/domain/repositories/student_user_profile_repository.dart';

class HousingRepositoryImpl implements HousingRepository {
  final FirebaseFirestore _firestore;
  final StudentUserProfileRepository _userProfileRepo;
  final ReviewsRepository _reviewsRepo;

  HousingRepositoryImpl(this._firestore, this._userProfileRepo, this._reviewsRepo);

  static const String _housingCollection = 'HousingPost';

  @override
  Future<HousingPostEntity?> getPostDetails({required String postId}) async {
    try {
      final docSnapshot = await _firestore.collection(_housingCollection).doc(postId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      var postModel = HousingPostModel.fromMap(docSnapshot.data()!, documentId: docSnapshot.id);

      if (postModel.reviewsPath != null && postModel.reviewsPath!.isNotEmpty) {
        final reviews = await _reviewsRepo.getPostReviews(reviewsPath: postModel.reviewsPath!);
        if (reviews != null) {
          postModel = postModel.copyWith(reviews: reviews as ReviewsModel);
        }
      }

      return postModel;
    } catch (e) {
      print('Error en getPostDetails: $e');
      rethrow; 
    }
  }

  @override
  Future<List<HousingPostEntity>> getRecommendedPosts(
    {required String userId}) async {
    try {

      final housingIds = await _userProfileRepo.getRecommendedHousingIds(userId);

      if (housingIds.isEmpty) {
        return [];
      }

      final housingPostsFutures =
          housingIds.map((id) => getPostDetails(postId: id));
      final housingPosts = await Future.wait(housingPostsFutures);

      return housingPosts.whereType<HousingPostEntity>().toList();
    } catch (e) {
      print('Error en getRecommendedPosts: $e');
      rethrow;
    }
  }

  @override
  Future<List<HousingPostEntity>> getRecentlyViewedPosts(
      {required String userId}) async {
    try {

      final housingIds = await _userProfileRepo.getVisitedHousingIds(userId);

      if (housingIds.isEmpty) {
        return [];
      }

      final housingPostsFutures =
          housingIds.map((id) => getPostDetails(postId: id));
      final housingPosts = await Future.wait(housingPostsFutures);

      return housingPosts.whereType<HousingPostEntity>().toList();
    } catch (e) {
      print('Error en getRecentlyViewedPosts: $e');
      rethrow;
    }
  }

  @override
  Future<List<HousingPostEntity>> findPostsNearLocation({
    required double lat,
    required double lng,
    required double radiusInKm,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_housingCollection)
          .where('status', isEqualTo: 'available')
          .get();

      final postFutures = querySnapshot.docs.map((doc) {
        return getPostDetails(postId: doc.id);
      }).toList();

      final posts = await Future.wait(postFutures);

      return posts.whereType<HousingPostEntity>().toList();
    } catch (e) {
      print('Error en findPostsNearLocation: $e');
      rethrow;
    }
  }
}