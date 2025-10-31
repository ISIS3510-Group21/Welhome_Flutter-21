import 'package:welhome/features/filter/domain/repositories/property_repository.dart';

class GetAllTagsUseCase {
  final PropertyRepository repository;

  GetAllTagsUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getAllTags();
  }
}