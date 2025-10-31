import 'package:welhome/features/housing/domain/entities/reviews_entity.dart';
import 'package:welhome/features/housing/domain/repositories/reviews_repository.dart';

class GetPostReviews {
  final ReviewsRepository repository;

  GetPostReviews(this.repository);

  Future<ReviewsEntity?> call({required String reviewsPath}) async {
    return await repository.getPostReviews(reviewsPath: reviewsPath);
  }
}