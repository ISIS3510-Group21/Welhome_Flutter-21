import 'package:welhome/features/housing/domain/entities/reviews_entity.dart';


abstract class ReviewsRepository {

  Future<ReviewsEntity?> getPostReviews({
    required String reviewsPath,
  });
}