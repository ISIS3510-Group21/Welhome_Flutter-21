import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/housing/domain/repositories/housing_repository.dart';

class GetPostDetails {
  final HousingRepository repository;

  GetPostDetails(this.repository);

  Future<HousingPostEntity?> call({required String postId}) async {
    if (postId.isEmpty) {
      throw ArgumentError('Post ID cannot be empty');
    }
    return await repository.getPostDetails(postId: postId);
  }
}