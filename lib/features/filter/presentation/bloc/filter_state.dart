import 'package:welhome/features/filter/domain/entities/property.dart';

abstract class FilterState {}

class FilterLoading extends FilterState {}
class FilterLoaded extends FilterState {
  final List<Property> properties;
  final Map<String, dynamic> availableTags;
  FilterLoaded(this.properties, this.availableTags);
}
class FilterError extends FilterState {
  final String message;
  FilterError(this.message);
}