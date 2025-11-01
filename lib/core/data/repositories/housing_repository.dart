import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/core/data/models/ammenities.dart';
import 'package:welhome/core/data/models/housing_post.dart';

class HousingRepository {
  final FirebaseFirestore _firestore;

  HousingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String housingCollection = 'HousingPost';

  double _calculateDistanceInKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371;
    
    final double lat1Rad = lat1 * pi / 180;
    final double lat2Rad = lat2 * pi / 180;
    final double deltaLatRad = (lat2 - lat1) * pi / 180;
    final double deltaLonRad = (lon2 - lon1) * pi / 180;

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  Future<List<HousingPostWithDistance>> getHousingPostsWithDistance(
    double userLat, 
    double userLng,
  ) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(housingCollection)
          .where('status', isEqualTo: 'available')
          .get();

      final List<HousingPostWithDistance> postsWithDistance = [];

      for (final doc in snapshot.docs) {
        try {
          final housingPost = HousingPost.fromMap(
            doc.data() as Map<String, dynamic>, 
            documentId: doc.id
          );
          
          // Calculate distance for each post but don't filter here
          final housingPostWithDistance = HousingPostWithDistance.fromHousingPost(
            housingPost,
            userLat,
            userLng,
          );
          postsWithDistance.add(housingPostWithDistance);
        } catch (e) {
          print('Error processing document ${doc.id}: $e');
        }
      }

      // Sort by distance but let UI handle filtering
      postsWithDistance.sort((a, b) => a.distanceInKm.compareTo(b.distanceInKm));

      return postsWithDistance;

    } on FirebaseException catch (e) {
      throw HousingRepositoryException(
        'Firebase error: ${e.message}',
        errorCode: e.code,
      );
    } catch (e) {
      throw HousingRepositoryException('Unexpected error: $e');
    }
  }

  Future<List<HousingPost>> getAllHousingPosts() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(housingCollection)
          .where('status', isEqualTo: 'available')
          .orderBy('creationDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HousingPost.fromMap(
                doc.data() as Map<String, dynamic>,
                documentId: doc.id,
              ))
          .toList();
    } on FirebaseException catch (e) {
      throw HousingRepositoryException(
        'Error getting housing posts: ${e.message}',
        errorCode: e.code,
      );
    }
  }

  Future<List<HousingPost>> getHousingPostsByHost(String hostId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(housingCollection)
          .where('host', isEqualTo: hostId)
          .orderBy('creationDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HousingPost.fromMap(
                doc.data() as Map<String, dynamic>,
                documentId: doc.id,
              ))
          .toList();
    } on FirebaseException catch (e) {
      throw HousingRepositoryException(
        'Error getting host posts: ${e.message}',
        errorCode: e.code,
      );
    }
  }

  Future<HousingPost?> getHousingPostById(String postId) async {
  try {
    final DocumentSnapshot doc = await _firestore
        .collection(housingCollection)
        .doc(postId)
        .get();

    if (doc.exists) {
      final housingPost = HousingPost.fromMap(
        doc.data() as Map<String, dynamic>,
        documentId: doc.id,
      );

      final picsSnapshot = await _firestore
          .collection(housingCollection)
          .doc(postId)
          .collection('Pictures')
          .get();

      final pictures = picsSnapshot.docs
          .map((d) => Picture.fromMap(d.data()))
          .toList();

      final ammenSnapshot = await _firestore
        .collection(housingCollection)
        .doc(postId)
        .collection('Ammenities')
        .get();

      final ammenities = ammenSnapshot.docs
          .map((d) => Ammenities.fromMap(d.data(), documentId: d.id))
          .toList();
          print('Ammenities fetched: ${ammenities.length}');
          print('Ammenities data: ${ammenities.map((a) => a.toMap()).toList()}');

      final roomateSnapshot = await _firestore
        .collection(housingCollection)
        .doc(postId)
        .collection('RoomateProfile')
        .get();

      final roomateProfile = roomateSnapshot.docs
          .map((d) => RoomateProfile.fromMap(d.data()))
          .toList();

      return housingPost.copyWith(pictures: pictures, ammenities: ammenities, roomateProfile: roomateProfile);
    }
    return null;
  } on FirebaseException catch (e) {
    throw HousingRepositoryException(
      'Error getting housing post: ${e.message}',
      errorCode: e.code,
    );
  }
}


  Future<String> createHousingPost(HousingPost post) async {
    try {
      final DocumentReference docRef = await _firestore
          .collection(housingCollection)
          .add(post.toMap());

      return docRef.id;
    } on FirebaseException catch (e) {
      throw HousingRepositoryException(
        'Error creating housing post: ${e.message}',
        errorCode: e.code,
      );
    }
  }

  Future<void> updateHousingPost(String postId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(housingCollection)
          .doc(postId)
          .update({
            ...updates,
            'updateAt': FieldValue.serverTimestamp(),
          });
    } on FirebaseException catch (e) {
      throw HousingRepositoryException(
        'Error updating housing post: ${e.message}',
        errorCode: e.code,
      );
    }
  }

  Future<void> deleteHousingPost(String postId) async {
    try {
      await _firestore
          .collection(housingCollection)
          .doc(postId)
          .delete();
    } on FirebaseException catch (e) {
      throw HousingRepositoryException(
        'Error deleting housing post: ${e.message}',
        errorCode: e.code,
      );
    }
  }

  Future<List<HousingPost>> getHousingPostsByCriteria({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    List<String>? amenities,
  }) async {
    try {
      Query query = _firestore.collection(housingCollection);

      // Add filters based on provided criteria
      if (minPrice != null && maxPrice != null) {
        query = query
            .where('price', isGreaterThanOrEqualTo: minPrice)
            .where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      final QuerySnapshot snapshot = await query.get();

      return snapshot.docs
          .map((doc) => HousingPost.fromMap(
                doc.data() as Map<String, dynamic>,
                documentId: doc.id,
              ))
          .toList();
    } on FirebaseException catch (e) {
      throw HousingRepositoryException(
        'Error getting posts by criteria: ${e.message}',
        errorCode: e.code,
      );
    }
  }
}

class HousingRepositoryException implements Exception {
  final String message;
  final String? errorCode;

  const HousingRepositoryException(this.message, {this.errorCode});

  @override
  String toString() => 'HousingRepositoryException: $message'
      '${errorCode != null ? ' (Code: $errorCode)' : ''}';
}