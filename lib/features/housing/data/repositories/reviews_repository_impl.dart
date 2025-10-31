import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/housing/data/models/reviews_model.dart';
import 'package:welhome/features/housing/domain/entities/reviews_entity.dart';
import 'package:welhome/features/housing/domain/repositories/reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final FirebaseFirestore _firestore;

  ReviewsRepositoryImpl(this._firestore);

  @override
  Future<ReviewsEntity?> getPostReviews({required String reviewsPath}) async {
    if (reviewsPath.isEmpty) {
      return null;
    }

    final pathParts = reviewsPath.trim().split('/').where((part) => part.isNotEmpty).toList();

    if (pathParts.length != 2) {
      print('Error: Invalid reviews path format after parsing: $reviewsPath -> $pathParts');
      return null;
    }

    final collectionName = pathParts[0];
    final documentId = pathParts[1];

    final reviewsSnapshot = await _firestore.collection(collectionName).doc(documentId).get();
    print('Fetched reviews from $reviewsPath: ${reviewsSnapshot.data()}');
    return reviewsSnapshot.exists ? ReviewsModel.fromMap(reviewsSnapshot.data()!, documentId: reviewsSnapshot.id) : null;
  }
}