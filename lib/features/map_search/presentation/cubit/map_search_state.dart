part of 'map_search_cubit.dart';

abstract class MapSearchState extends Equatable {
  const MapSearchState();

  @override
  List<Object?> get props => [];
}

class MapSearchInitial extends MapSearchState {}

class MapSearchLoading extends MapSearchState {}

class MapSearchLoaded extends MapSearchState {
  final List<HousingPostEntity> properties;
  final HousingPostEntity? selectedProperty;

  const MapSearchLoaded({
    required this.properties,
    this.selectedProperty,
  });

  @override
  List<Object?> get props => [properties, selectedProperty];
}

class MapSearchError extends MapSearchState {
  final String message;

  const MapSearchError(this.message);
}