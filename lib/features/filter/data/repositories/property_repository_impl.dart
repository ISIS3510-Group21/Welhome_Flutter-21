import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/filter/data/datasources/property_remote_datasource.dart';
import 'package:welhome/features/filter/domain/entities/property.dart';
import 'package:welhome/features/filter/domain/repositories/property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource dataSource;
  
  PropertyRepositoryImpl(this.dataSource);
  
  @override
  Future<(List<Property>, DocumentSnapshot?)> getProperties({
    List<String>? selectedAmenities,
    List<String>? selectedHousingTags,
    DocumentSnapshot? lastDocument,
    int pageSize = 20,
  }) async {
    final (propertyModels, lastDoc) = await dataSource.getProperties(
      selectedAmenities: selectedAmenities,
      selectedHousingTags: selectedHousingTags,
      lastDocument: lastDocument,
      pageSize: pageSize,
    );
    return (propertyModels.map((model) => model.toDomain()).toList(), lastDoc);
  }

  @override
  Future<Map<String, dynamic>> getAllTags() async {
    return dataSource.getAllTags();
  }
}