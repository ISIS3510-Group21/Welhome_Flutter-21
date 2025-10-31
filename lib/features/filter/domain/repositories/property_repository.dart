import 'package:welhome/features/filter/domain/entities/property.dart';

abstract class PropertyRepository {
  Future<List<Property>> getProperties({
    List<String>? selectedAmenities,
    List<String>? selectedHousingTags,
  });
  Future<Map<String, dynamic>> getAllTags();
}