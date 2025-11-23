import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_with_distance_entity.dart';

abstract class MapSearchState extends Equatable {
  const MapSearchState();
  
  @override
  List<Object?> get props => [];
}

class MapSearchInitial extends MapSearchState {}

class MapSearchLoadingLocation extends MapSearchState {
  final String message;
  
  const MapSearchLoadingLocation({this.message = "Getting your location..."});
  
  @override
  List<Object> get props => [message];
}

class MapSearchLoadingPosts extends MapSearchState {
  final LatLng userLocation;
  final String message;
  
  const MapSearchLoadingPosts({
    required this.userLocation,
    this.message = "Finding nearby accommodations...",
  });
  
  @override
  List<Object> get props => [userLocation, message];
}

class MapSearchLoaded extends MapSearchState {
  final LatLng userLocation;
  final List<HousingPostWithDistanceEntity> housingPostsWithDistance;
  final int totalResults;
  final double searchRadiusKm;
  final String? selectedPostId;
  
  const MapSearchLoaded({
    required this.userLocation,
    required this.housingPostsWithDistance,
    required this.totalResults,
    this.searchRadiusKm = 15.0,
    this.selectedPostId,
  });
  
  bool get hasResults => housingPostsWithDistance.isNotEmpty;
  
  int get displayedResults => housingPostsWithDistance.length;
  
  @override
  List<Object?> get props => [
        userLocation,
        housingPostsWithDistance,
        totalResults,
        searchRadiusKm,
        selectedPostId ?? '',
      ];
  
  MapSearchLoaded copyWith({
    LatLng? userLocation,
    List<HousingPostWithDistanceEntity>? housingPostsWithDistance,
    int? totalResults,
    double? searchRadiusKm,
    String? selectedPostId,
  }) {
    return MapSearchLoaded(
      userLocation: userLocation ?? this.userLocation,
      housingPostsWithDistance: housingPostsWithDistance ?? this.housingPostsWithDistance,
      totalResults: totalResults ?? this.totalResults,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
      selectedPostId: selectedPostId ?? this.selectedPostId,
    );
  }
}

class MapSearchNoResults extends MapSearchState {
  final LatLng userLocation;
  final double searchRadiusKm;
  
  const MapSearchNoResults({
    required this.userLocation,
    this.searchRadiusKm = 15.0,
  });
  
  @override
  List<Object> get props => [userLocation, searchRadiusKm];
}

class MapSearchError extends MapSearchState {
  final String message;
  final String? errorCode;
  final LatLng? lastUserLocation;
  final List<HousingPostWithDistanceEntity>? lastHousingPosts;
  final bool canRetry;
  
  const MapSearchError({
    required this.message,
    this.errorCode,
    this.lastUserLocation,
    this.lastHousingPosts,
    this.canRetry = true,
  });
  
  @override
  List<Object?> get props => [
        message,
        errorCode,
        lastUserLocation,
        lastHousingPosts,
        canRetry,
      ];
  
  bool get hasPreviousData => lastHousingPosts != null && lastHousingPosts!.isNotEmpty;
  
  MapSearchError copyWith({
    String? message,
    String? errorCode,
    LatLng? lastUserLocation,
    List<HousingPostWithDistanceEntity>? lastHousingPosts,
    bool? canRetry,
  }) {
    return MapSearchError(
      message: message ?? this.message,
      errorCode: errorCode ?? this.errorCode,
      lastUserLocation: lastUserLocation ?? this.lastUserLocation,
      lastHousingPosts: lastHousingPosts ?? this.lastHousingPosts,
      canRetry: canRetry ?? this.canRetry,
    );
  }
}

class MapSearchRefreshing extends MapSearchState {
  final LatLng userLocation;
  final List<HousingPostWithDistanceEntity> currentPosts;
  final double newSearchRadiusKm;
  final String? selectedPostId;
  
  const MapSearchRefreshing({
    required this.userLocation,
    required this.currentPosts,
    this.newSearchRadiusKm = 15.0,
    this.selectedPostId,
  });
  
  @override
  List<Object> get props => [userLocation, currentPosts, newSearchRadiusKm, selectedPostId ?? ''];
}