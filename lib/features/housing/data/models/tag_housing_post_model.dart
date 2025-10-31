import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/housing/domain/entities/tag_housing_post_entity.dart';

class TagHousingPostModel extends TagHousingPostEntity {
  final DocumentReference? housingTag;

  const TagHousingPostModel({
    required super.id,
    required super.name,
    this.housingTag,
  });

  factory TagHousingPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TagHousingPostModel(
      id: doc.id,
      name: data['name'] ?? '',
      housingTag: data['housingTag'] as DocumentReference?,
    );
  }

  factory TagHousingPostModel.fromMap(Map<String, dynamic> data) {
    return TagHousingPostModel(
      id: data['id'] ?? "",
      name: data['name'] ?? "",
      housingTag: data['housingTag'] as DocumentReference?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'housingTag': housingTag,
    };
  }
}
