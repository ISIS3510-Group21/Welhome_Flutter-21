abstract class FilterEvent {}

class LoadInitialProperties extends FilterEvent {}
class UpdateFilters extends FilterEvent {
  final List<String> amenities;
  final List<String> housingTags;
  UpdateFilters(this.amenities, this.housingTags);
}
