import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/housing/domain/entities/tag_housing_post_entity.dart';

class TagHousingPostModel extends TagHousingPostEntity {
  const TagHousingPostModel({
    required super.id,
    required super.name,
    required super.housingTag, // Cambiar a String para ser consistente
  });

  factory TagHousingPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    String? coerceDocPath(dynamic raw) {
      if (raw == null) return null;
      if (raw is String) return raw;
      if (raw is DocumentReference) return raw.path;
      return raw.toString();
    }

    String coerceString(dynamic raw, [String defaultValue = '']) {
      if (raw == null) return defaultValue;
      if (raw is String) return raw;
      return raw.toString();
    }

    return TagHousingPostModel(
      id: doc.id,
      name: coerceString(data['name']),
      housingTag: coerceDocPath(data['housingTag']), // Ahora es String
    );
  }

  factory TagHousingPostModel.fromMap(Map<String, dynamic> data) {
    String? coerceDocPath(dynamic raw) {
      if (raw == null) return null;
      if (raw is String) return raw;
      if (raw is DocumentReference) return raw.path;
      return raw.toString();
    }

    String coerceString(dynamic raw, [String defaultValue = '']) {
      if (raw == null) return defaultValue;
      if (raw is String) return raw;
      return raw.toString();
    }

    return TagHousingPostModel(
      id: coerceString(data['id']),
      name: coerceString(data['name']),
      housingTag: coerceDocPath(data['housingTag']), // Aplicar coerción aquí
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'housingTag': housingTag, // Ahora es String
    };
  }
}