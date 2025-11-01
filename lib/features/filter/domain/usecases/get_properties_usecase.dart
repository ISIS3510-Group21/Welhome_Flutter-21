import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/filter/domain/entities/property.dart';
import 'package:welhome/features/filter/domain/repositories/property_repository.dart';

class GetPropertiesUseCase {
  final PropertyRepository repository;
  
  GetPropertiesUseCase(this.repository);
  
  Future<(List<Property>, DocumentSnapshot?)> call({
    List<String>? selectedAmenities,
    List<String>? selectedHousingTags,
    DocumentSnapshot? lastDocument,
    int pageSize = 20,
  }) {
    return repository.getProperties(
      selectedAmenities: selectedAmenities,
      selectedHousingTags: selectedHousingTags,
      lastDocument: lastDocument,
      pageSize: pageSize,
    );
  }
}