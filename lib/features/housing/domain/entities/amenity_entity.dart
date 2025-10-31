import 'package:equatable/equatable.dart';

class AmenityEntity extends Equatable {
  final String id;
  final String name;
  final String iconPath;

  const AmenityEntity({
    required this.id,
    required this.name,
    required this.iconPath,
  });

  @override
  List<Object?> get props => [id, name];
}