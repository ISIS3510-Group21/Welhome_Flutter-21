import 'package:welhome/features/filter/data/datasources/property_remote_datasource.dart';
import 'package:welhome/features/filter/domain/entities/property.dart';
import 'package:welhome/features/filter/domain/repositories/property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource dataSource;
  
  PropertyRepositoryImpl(this.dataSource);
  
  @override
  Future<List<Property>> getProperties({
    List<String>? selectedAmenities,
    List<String>? selectedHousingTags,
  }) async {
    final propertyModels = await dataSource.getProperties(
      selectedAmenities: selectedAmenities,
      selectedHousingTags: selectedHousingTags,
    );
    return propertyModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<Map<String, dynamic>> getAllTags() async {
    return dataSource.getAllTags();
  }
}