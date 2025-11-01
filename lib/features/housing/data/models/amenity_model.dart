import 'package:welhome/features/housing/domain/entities/amenity_entity.dart';

class AmenityModel extends AmenityEntity {
  const AmenityModel({
    required super.id,
    required super.name,
    required super.iconPath,
  });

  factory AmenityModel.fromMap(Map<String, dynamic> data, {String? documentId}) {
    return AmenityModel(
      id: documentId ?? data['id'] ?? '',
      name: data['name'] ?? '',
      iconPath: data['iconPath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
    };
  }
}
