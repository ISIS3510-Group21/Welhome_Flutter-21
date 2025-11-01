import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:welhome/features/filter/domain/usecases/get_properties_usecase.dart';
import 'package:welhome/features/filter/domain/usecases/get_all_tags_usecase.dart';
import 'package:welhome/features/filter/presentation/bloc/filter_event.dart';
import 'package:welhome/features/filter/presentation/bloc/filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  final GetPropertiesUseCase getPropertiesUseCase;
  final GetAllTagsUseCase getAllTagsUseCase;
  List<String> _currentAmenities = [];
  List<String> _currentHousingTags = [];
  static const int _pageSize = 20;

  FilterBloc({
    required this.getPropertiesUseCase,
    required this.getAllTagsUseCase,
  }) : super(FilterLoading()) {
    on<LoadInitialProperties>(_onLoadInitialProperties);
    on<LoadMoreProperties>(_onLoadMoreProperties);
    on<UpdateFilters>(_onUpdateFilters);
  }

  Future<void> _onLoadInitialProperties(
    LoadInitialProperties event,
    Emitter<FilterState> emit,
  ) async {
    emit(FilterLoading());
    
    try {
      final availableTags = await getAllTagsUseCase();
      final (properties, lastDoc) = await getPropertiesUseCase(
        selectedAmenities: _currentAmenities,
        selectedHousingTags: _currentHousingTags,
        pageSize: _pageSize,
      );

      emit(FilterLoaded(
        properties: properties,
        availableTags: availableTags,
        hasMore: properties.length >= _pageSize,
        lastDocument: lastDoc,
      ));
    } catch (e) {
      emit(FilterError('Failed to load properties: $e'));
    }
  }

  Future<void> _onLoadMoreProperties(
    LoadMoreProperties event,
    Emitter<FilterState> emit,
  ) async {
    final currentState = state;
    if (currentState is FilterLoaded && !currentState.isLoadingMore && currentState.hasMore) {
      try {
        emit(currentState.copyWith(isLoadingMore: true));
        
        final (newProperties, lastDoc) = await getPropertiesUseCase(
          selectedAmenities: _currentAmenities,
          selectedHousingTags: _currentHousingTags,
          lastDocument: currentState.lastDocument,
          pageSize: _pageSize,
        );

        emit(FilterLoaded(
          properties: [...currentState.properties, ...newProperties],
          availableTags: currentState.availableTags,
          hasMore: newProperties.length >= _pageSize,
          lastDocument: lastDoc,
          isLoadingMore: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _onUpdateFilters(
    UpdateFilters event,
    Emitter<FilterState> emit,
  ) async {
    _currentAmenities = event.selectedAmenities;
    _currentHousingTags = event.selectedHousingTags;
    
    emit(FilterLoading());
    
    try {
      final (properties, lastDoc) = await getPropertiesUseCase(
        selectedAmenities: _currentAmenities,
        selectedHousingTags: _currentHousingTags,
        pageSize: _pageSize,
      );

      final currentState = state;
      if (currentState is FilterLoaded) {
        emit(FilterLoaded(
          properties: properties,
          availableTags: currentState.availableTags,
          hasMore: properties.length >= _pageSize,
          lastDocument: lastDoc,
        ));
      }
    } catch (e) {
      emit(FilterError('Failed to update filters: $e'));
    }
  }
}
