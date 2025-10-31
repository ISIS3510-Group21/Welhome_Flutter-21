import 'package:welhome/features/housing/domain/entities/roomate_profile_entity.dart';

class RoomateProfileModel extends RoomateProfileEntity {
  const RoomateProfileModel({
    String id = "",
    String name = "",
    String studentUserID = "",
  }) : super(id: id, name: name, studentUserID: studentUserID);

  factory RoomateProfileModel.fromMap(Map<String, dynamic> data) {
    return RoomateProfileModel(
      id: data['id'] ?? "",
      name: data['name'] ?? "",
      studentUserID: data['studentUserID'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'studentUserID': studentUserID,
    };
  }
}