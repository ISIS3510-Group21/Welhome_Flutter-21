import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/filter/domain/entities/property.dart';

abstract class PropertyRepository {
  Future<(List<Property>, DocumentSnapshot?)> getProperties({
    List<String>? selectedAmenities,
    List<String>? selectedHousingTags,
    DocumentSnapshot? lastDocument,
    int pageSize,
  });
  Future<Map<String, dynamic>> getAllTags();
}