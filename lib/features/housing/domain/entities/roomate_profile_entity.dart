import 'package:equatable/equatable.dart';

class RoomateProfileEntity extends Equatable {
  final String id;
  final String name;
  final String studentUserID;

  const RoomateProfileEntity(
      {required this.id, required this.name, required this.studentUserID});

  @override
  List<Object?> get props => [id, studentUserID];
}