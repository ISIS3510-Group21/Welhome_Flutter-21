import 'package:equatable/equatable.dart';

class ReviewsEntity extends Equatable {
  final String id;
  final double rating;
  final int reviewQuantity;

  const ReviewsEntity({
    required this.id,
    required this.rating,
    required this.reviewQuantity,
  });

  @override
  List<Object?> get props => [id, rating, reviewQuantity];
}