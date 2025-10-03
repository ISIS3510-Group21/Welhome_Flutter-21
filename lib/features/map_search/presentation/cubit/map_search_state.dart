import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:welhome/core/data/models/housing_post.dart';
import 'package:welhome/core/data/repositories/housing_repository.dart';

abstract class MapSearchState extends Equatable {
  const MapSearchState();
  
  @override
  List<Object?> get props => [];
}

// Initial state - when the screen is ready to start
class MapSearchInitial extends MapSearchState {}

// State when the user's location is loading
class MapSearchLoadingLocation extends MapSearchState {
  final String message;
  
  const MapSearchLoadingLocation({this.message = "Getting your location..."});
  
  @override
  List<Object> get props => [message];
}

// State when the user's location is loaded and the posts are loading
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


// Final state when everything is loaded and ready
class MapSearchLoaded extends MapSearchState {
  final LatLng userLocation;
  final List<HousingPostWithDistance> housingPostsWithDistance;
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
  
  // Getter to check if there are results
  bool get hasResults => housingPostsWithDistance.isNotEmpty;
  
  // Getter for number of displayed results
  int get displayedResults => housingPostsWithDistance.length;
  
  @override
  List<Object> get props => [
        userLocation,
        housingPostsWithDistance,
        totalResults,
        searchRadiusKm,
        selectedPostId ?? '',
      ];
  
  MapSearchLoaded copyWith({
    LatLng? userLocation,
    List<HousingPostWithDistance>? housingPostsWithDistance,
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

// State when no results were found
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

// Error state with relevant information
class MapSearchError extends MapSearchState {
  final String message;
  final String? errorCode;
  final LatLng? lastUserLocation;
  final List<HousingPostWithDistance>? lastHousingPosts;
  final bool canRetry;
  
  const MapSearchError({
    required this.message,
    this.errorCode,
    this.lastUserLocation,
    this.lastHousingPosts,
    this.canRetry = true,
  });
  
  // Factory constructor for Firebase errors
  factory MapSearchError.fromRepositoryException(
    HousingRepositoryException exception, {
    LatLng? lastUserLocation,
    List<HousingPostWithDistance>? lastHousingPosts,
  }) {
    return MapSearchError(
      message: _getUserFriendlyMessage(exception),
      errorCode: exception.errorCode,
      lastUserLocation: lastUserLocation,
      lastHousingPosts: lastHousingPosts,
      canRetry: _isRetryableError(exception.errorCode),
    );
  }
  
  static String _getUserFriendlyMessage(HousingRepositoryException exception) {
    final errorCode = exception.errorCode;
    
    if (errorCode == 'permission-denied') {
      return 'You do not have permission to access accommodations';
    } else if (errorCode == 'unavailable') {
      return 'Service is currently unavailable';
    } else if (errorCode == 'resource-exhausted') {
      return 'Query limit reached. Please try again later';
    } else {
      return exception.message;
    }
  }
  
  static bool _isRetryableError(String? errorCode) {
    const nonRetryableErrors = [
      'permission-denied',
      'invalid-argument',
    ];
    
    return errorCode == null || !nonRetryableErrors.contains(errorCode);
  }
  
  @override
  List<Object?> get props => [
        message,
        errorCode,
        lastUserLocation,
        lastHousingPosts,
        canRetry,
      ];
  
  // Getter to check if there is previous data to show
  bool get hasPreviousData => lastHousingPosts != null && lastHousingPosts!.isNotEmpty;
  
  MapSearchError copyWith({
    String? message,
    String? errorCode,
    LatLng? lastUserLocation,
    List<HousingPostWithDistance>? lastHousingPosts,
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

// State for when performing a new search with different parameters
class MapSearchRefreshing extends MapSearchState {
  final LatLng userLocation;
  final List<HousingPostWithDistance> currentPosts;
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
