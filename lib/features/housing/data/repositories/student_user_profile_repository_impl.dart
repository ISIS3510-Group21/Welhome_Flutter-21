import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/housing/domain/repositories/student_user_profile_repository.dart';

class StudentUserProfileRepositoryImpl implements StudentUserProfileRepository {
  final FirebaseFirestore _firestore;

  StudentUserProfileRepositoryImpl(this._firestore);

  static const String _studentProfilesCollection = 'StudentUserProfile';

  @override
  Future<List<String>> getVisitedHousingIds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_studentProfilesCollection)
          .doc(userId)
          .collection('VisitedHousingPosts')
          .get();

      print('Fetched visited housing IDs for user $userId: ${snapshot.docs.map((doc) => doc['housing'] as String).toList()}');
      return snapshot.docs.map((doc) => doc['housing'] as String).toList();
    } catch (e) {
      print('Error getting visited housing IDs for user $userId: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getRecommendedHousingIds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_studentProfilesCollection)
          .doc(userId)
          .collection('RecommendedHousingPosts')
          .get();

      return snapshot.docs.map((doc) => doc['housing'] as String).toList();
    } catch (e) {
      print('Error getting recommended housing IDs for user $userId: $e');
      rethrow;
    }
  }
}