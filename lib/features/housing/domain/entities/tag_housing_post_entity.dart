import 'package:equatable/equatable.dart';

class TagHousingPostEntity extends Equatable {
  final String id;
  final String name;
  final String? housingTag; // Cambiado a String para ser consistente

  const TagHousingPostEntity({
    required this.id,
    required this.name,
    required this.housingTag,
  });

  @override
  List<Object?> get props => [id, name];
}