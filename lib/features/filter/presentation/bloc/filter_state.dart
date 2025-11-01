import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/filter/domain/entities/property.dart';

abstract class FilterState {}

class FilterLoading extends FilterState {}

class FilterLoaded extends FilterState {
  final List<Property> properties;
  final Map<String, dynamic> availableTags;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;
  final bool isLoadingMore;
  
  FilterLoaded({
    required this.properties,
    required this.availableTags,
    this.hasMore = true,
    this.lastDocument,
    this.isLoadingMore = false,
  });

  FilterLoaded copyWith({
    List<Property>? properties,
    Map<String, dynamic>? availableTags,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
    bool? isLoadingMore,
  }) {
    return FilterLoaded(
      properties: properties ?? this.properties,
      availableTags: availableTags ?? this.availableTags,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class FilterError extends FilterState {
  final String message;
  FilterError(this.message);
}