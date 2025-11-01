abstract class FilterEvent {}

class LoadInitialProperties extends FilterEvent {}

class LoadMoreProperties extends FilterEvent {}

class UpdateFilters extends FilterEvent {
  final List<String> selectedAmenities;
  final List<String> selectedHousingTags;
  
  UpdateFilters({
    required this.selectedAmenities,
    required this.selectedHousingTags,
  });
}
