import 'package:welhome/features/housing/domain/entities/amenity_entity.dart';

class AmenityModel extends AmenityEntity {
  const AmenityModel({
    required String id,
    required String name,
    required String iconPath,
  }) : super(id: id, name: name, iconPath: iconPath);

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
