import 'package:welhome/features/housing/domain/entities/reviews_entity.dart';

class ReviewsModel extends ReviewsEntity {
  const ReviewsModel({
    required super.id,
    required super.rating,
    required super.reviewQuantity,
  });

  factory ReviewsModel.fromMap(Map<String, dynamic> data, {String? documentId}) {
    return ReviewsModel(
      id: documentId ?? data['id'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewQuantity: (data['reviewQuantity'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rating': rating,
      'reviewQuantity': reviewQuantity,
    };
  }
}
