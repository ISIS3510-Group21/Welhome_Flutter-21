import 'package:welhome/features/filter/domain/entities/property.dart';
import 'package:welhome/features/filter/domain/repositories/property_repository.dart';

class GetPropertiesUseCase {
  final PropertyRepository repository;
  
  GetPropertiesUseCase(this.repository);
  
  Future<List<Property>> call({
    List<String>? selectedAmenities,
    List<String>? selectedHousingTags,
  }) {
    return repository.getProperties(
      selectedAmenities: selectedAmenities,
      selectedHousingTags: selectedHousingTags,
    );
  }
}