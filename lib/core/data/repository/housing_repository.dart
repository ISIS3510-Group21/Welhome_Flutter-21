import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/core/data/models/housing_post.dart';

class HousingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<HousingPost>> getNearbyHousingPosts(
    double userLat,
    double userLng, {
    double radiusInMeters = 1000,
  }) async {
    // Calculate Bouniding Box
    double latDelta = radiusInMeters / 111320; // 1° latitud ≈ 111.32 km
    double lngDelta =
        radiusInMeters / (111320 * cos(userLat * pi / 180));

    double minLat = userLat - latDelta;
    double maxLat = userLat + latDelta;
    double minLng = userLng - lngDelta;
    double maxLng = userLng + lngDelta;

    // Query Firestore by latitude
    final snapshot = await _firestore
        .collection('HousingPosts')
        .where('location.lat', isGreaterThanOrEqualTo: minLat)
        .where('location.lat', isLessThanOrEqualTo: maxLat)
        .get();

    // Filter by longitude
    final docs = snapshot.docs.where((doc) {
      final data = doc.data();
      final lat = (data['location']['lat'] ?? 0).toDouble();
      final lng = (data['location']['lng'] ?? 0).toDouble();
      return lng >= minLng && lng <= maxLng;
    });

    //  Convert to HousingPost
    final results = docs.map((doc) {
      return HousingPost.fromMap(doc.data(), documentId: doc.id);
    }).toList();

    return results;
  }
}
