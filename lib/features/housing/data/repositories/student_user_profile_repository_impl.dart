import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/housing/domain/repositories/student_user_profile_repository.dart';

class StudentUserProfileRepositoryImpl implements StudentUserProfileRepository {
  final FirebaseFirestore _firestore;

  StudentUserProfileRepositoryImpl(this._firestore);

  static const String _studentProfilesCollection = 'StudentProfiles';

  @override
  Future<List<String>> getVisitedHousingIds(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection(_studentProfilesCollection).doc(userId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('visitedHousingIds')) {
          return List<String>.from(data['visitedHousingIds'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error getting visited housing IDs for user $userId: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getRecommendedHousingIds(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection(_studentProfilesCollection).doc(userId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('recommendedHousingIds')) {
          return List<String>.from(data['recommendedHousingIds'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error getting recommended housing IDs for user $userId: $e');
      rethrow;
    }
  }
}