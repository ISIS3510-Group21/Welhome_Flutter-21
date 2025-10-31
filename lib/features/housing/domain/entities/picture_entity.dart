import 'package:equatable/equatable.dart';

class PictureEntity extends Equatable {
  final String photoPath;
  final String name;

  const PictureEntity({required this.photoPath, required this.name});

  @override
  List<Object?> get props => [photoPath, name];
}