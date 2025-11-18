import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/housing/domain/repositories/housing_repository.dart';

part 'map_search_state.dart';

class MapSearchCubit extends Cubit<MapSearchState> {
  final HousingRepository housingRepository;

  MapSearchCubit({required this.housingRepository}) : super(MapSearchInitial());

  Future<void> loadProperties() async {
    emit(MapSearchLoading());
    try {
      final properties = await housingRepository.findPostsNearLocation(
        lat: 34.0522,
        lng: -118.2437, 
        radiusInKm: 20,
      );
      emit(MapSearchLoaded(properties: properties));
    } catch (e) {
      emit(MapSearchError(e.toString()));
    }
  }

  void selectProperty(HousingPostEntity property) {
    if (state is MapSearchLoaded) {
      final currentState = state as MapSearchLoaded;
      emit(MapSearchLoaded(properties: currentState.properties, selectedProperty: property));
    }
  }

  void deselectProperty() {
    if (state is MapSearchLoaded) {
      final currentState = state as MapSearchLoaded;
      emit(MapSearchLoaded(properties: currentState.properties, selectedProperty: null));
    }
  }
}