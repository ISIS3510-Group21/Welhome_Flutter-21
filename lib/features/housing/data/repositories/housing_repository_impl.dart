import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:welhome/features/housing/data/models/housing_post_model.dart';
import 'package:welhome/features/housing/data/models/amenity_model.dart';
import 'package:welhome/features/housing/data/models/reviews_model.dart';
import 'package:welhome/features/housing/data/models/roomate_profile_model.dart';
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

      // CORREGIDO: Usar reviewsPath en lugar de reviewsReference
      final reviewsPath = postModel.reviewsPath;
      if (reviewsPath != null && reviewsPath.isNotEmpty) {
        final reviews = await _reviewsRepo.getPostReviews(reviewsPath: reviewsPath);
        if (reviews != null) {
          postModel = postModel.copyWith(reviews: reviews as ReviewsModel);
        }
      }

      final amenitiesSnapshot = await _firestore
          .collection(_housingCollection)
          .doc(postId)
          .collection('Ammenities')
          .get();

      final amenities = amenitiesSnapshot.docs.map((doc) => AmenityModel.fromMap(doc.data(), documentId: doc.id)).toList();
      print('Ammenities fetched: ${amenities.length}');
      print('Ammenities data: ${amenities.map((a) => a.toMap()).toList()}');
      postModel = postModel.copyWith(ammenities: amenities);

      final roomatesSnapshot = await _firestore
          .collection(_housingCollection)
          .doc(postId)
          .collection('RoomateProfile')
          .get();
          
      final roomates = roomatesSnapshot.docs.map((doc) => RoomateProfileModel.fromMap(doc.data())).toList();
      postModel = postModel.copyWith(roomateProfile: roomates);

      return postModel;
    } catch (e) {
      print('Error en getPostDetails: $e');
      rethrow; 
    }
  }

  @override
  Future<List<HousingPostEntity>> getRecommendedPosts({required String userId}) async {
    try {
      final housingIds = await _userProfileRepo.getRecommendedHousingIds(userId);

      if (housingIds.isEmpty) {
        return [];
      }

      final housingPostsFutures = housingIds.map((id) => getPostDetails(postId: id));
      final housingPosts = await Future.wait(housingPostsFutures);

      return housingPosts.whereType<HousingPostEntity>().toList();
    } catch (e) {
      print('Error en getRecommendedPosts: $e');
      rethrow;
    }
  }

  @override
  Future<List<HousingPostEntity>> getRecentlyViewedPosts({required String userId}) async {
    try {
      final housingIds = await _userProfileRepo.getVisitedHousingIds(userId);

      if (housingIds.isEmpty) {
        return [];
      }

      final housingPostsFutures = housingIds.map((id) => getPostDetails(postId: id));
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

      final allAvailablePosts = (await Future.wait(postFutures)).whereType<HousingPostEntity>().toList();

      final nearbyPosts = allAvailablePosts.where((post) {
        final distance = _calculateDistance(
          lat,
          lng,
          post.location.lat,
          post.location.lng,
        );
        return distance <= radiusInKm;
      }).toList();

      return nearbyPosts;
    } catch (e) {
      print('Error en findPostsNearLocation: $e');
      rethrow;
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    const c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  @override
  Future<List<HousingPostEntity>> getAllHousingPosts() async {
    try {
      final querySnapshot = await _firestore
          .collection(_housingCollection)
          .get();

      final postFutures = querySnapshot.docs.map((doc) {
        return getPostDetails(postId: doc.id);
      }).toList();

      final posts = await Future.wait(postFutures);

      return posts.whereType<HousingPostEntity>().toList();
    } catch (e) {
      print('Error en getAllHousingPosts: $e');
      rethrow;
    }
  }

  @override
  Future<List<HousingPostEntity>> getAllAvailableHousingPosts() async {
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
      print('Error en getAllAvailableHousingPosts: $e');
      rethrow;
    }
  }
}