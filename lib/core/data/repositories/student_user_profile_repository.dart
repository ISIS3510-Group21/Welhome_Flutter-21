import 'package:cloud_firestore/cloud_firestore.dart';

class StudentUserProfileRepository {
  final FirebaseFirestore _firestore;

  StudentUserProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<String>> getVisitedHousingIds(String userId) async {
    final snapshot = await _firestore
        .collection('StudentUserProfile')
        .doc(userId)
        .collection('VisitedHousingPosts')
        .get();

    return snapshot.docs
        .map((doc) => doc['housing'] as String)
        .toList();
  }

  Future<List<String>> getRecommendedHousingIds(String userId) async {
    final snapshot = await _firestore
        .collection('StudentUserProfile')
        .doc(userId)
        .collection('RecommendedHousingPosts')
        .get();

    return snapshot.docs
        .map((doc) => doc['housing'] as String)
        .toList();
  }
}
