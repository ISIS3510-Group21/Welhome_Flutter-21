import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/housing/data/models/housing_post_model.dart';
import 'package:welhome/features/housing/data/models/reviews_model.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/housing/domain/repositories/housing_repository.dart';
import 'package:welhome/features/housing/domain/repositories/student_user_profile_repository.dart';

class HousingRepositoryImpl implements HousingRepository {
  final FirebaseFirestore _firestore;
  final StudentUserProfileRepository _userProfileRepo;

  HousingRepositoryImpl(this._firestore, this._userProfileRepo);

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
        final pathParts = postModel.reviewsPath!.split('/');
        

        if (pathParts.length == 3) {
          final collectionName = pathParts[1];
          final documentId = pathParts[2];

          final reviewsSnapshot = await _firestore.collection(collectionName).doc(documentId).get();
          final reviewsModel = ReviewsModel.fromMap(reviewsSnapshot.data() as Map<String, dynamic>, documentId: reviewsSnapshot.id);
          postModel = postModel.copyWith(reviews: reviewsModel);
        }
      }

      return postModel;
    } catch (e) {
      print('Error en getPostDetails: $e');
      rethrow; 
    }
  }

  @override
  Future<List<HousingPostEntity>> getRecommendedPosts() async {
    try {

      final querySnapshot = await _firestore
          .collection(_housingCollection)
          .orderBy('creationDate', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => HousingPostModel.fromMap(doc.data(), documentId: doc.id))
          .toList();
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

      return querySnapshot.docs
          .map((doc) => HousingPostModel.fromMap(doc.data(), documentId: doc.id))
          .toList();
    } catch (e) {
      print('Error en findPostsNearLocation: $e');
      rethrow;
    }
  }
}