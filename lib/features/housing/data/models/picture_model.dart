import 'package:welhome/features/housing/domain/entities/picture_entity.dart';

class PictureModel extends PictureEntity {
  const PictureModel({
    super.photoPath = "",
    super.name = "",
  });

  factory PictureModel.fromMap(Map<String, dynamic> data) {
    return PictureModel(
      photoPath: data['photoPath'] ?? "",
      name: data['name'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photoPath': photoPath,
      'name': name,
    };
  }
}
