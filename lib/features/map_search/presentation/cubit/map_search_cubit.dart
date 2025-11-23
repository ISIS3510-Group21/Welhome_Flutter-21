import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:welhome/features/housing/domain/repositories/housing_repository.dart';
import 'map_search_state.dart';

class MapSearchCubit extends Cubit<MapSearchState> {
  final HousingRepository _housingRepository;

  MapSearchCubit(this._housingRepository) : super(MapSearchInitial());

  Future<void> getUserLocation() async {
    emit(const MapSearchLoadingLocation());
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const MapSearchError(
          message: 'Location services are disabled. Please enable them to find nearby accommodations.',
        ));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(const MapSearchError(
            message: 'Location permissions are required to find accommodations near you.',
            canRetry: false,
          ));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(const MapSearchError(
          message: 'Location permissions are permanently denied. Please enable them in your device settings.',
          canRetry: false,
        ));
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      final userLocation = LatLng(position.latitude, position.longitude);
      
      await loadHousingPostsWithDistance(userLocation);
      
    } catch (e) {
      emit(MapSearchError(
        message: 'Error getting location: ${e.toString()}',
      ));
    }
  }

  Future<void> loadHousingPostsWithDistance(LatLng userLocation) async {
    emit(MapSearchLoadingPosts(
      userLocation: userLocation,
      message: "Finding accommodations...",
    ));
    
    try {
      final postsWithDistance = await _housingRepository.getHousingPostsWithDistance(
        userLocation.latitude,
        userLocation.longitude,
      );

      const double radiusKm = 15.0;
      final filtered = postsWithDistance
          .where((p) => p.distanceInKm <= radiusKm)
          .toList();

      if (filtered.isEmpty) {
        emit(MapSearchNoResults(
          userLocation: userLocation,
        ));
      } else {
        emit(MapSearchLoaded(
          userLocation: userLocation,
          housingPostsWithDistance: filtered,
          totalResults: filtered.length,
          searchRadiusKm: radiusKm,
        ));
      }
      
    } catch (e) {
      emit(MapSearchError(
        message: 'Error loading accommodations: ${e.toString()}',
        lastUserLocation: userLocation,
      ));
    }
  }

  Future<void> refreshHousingPosts(LatLng userLocation) async {
    final currentState = state;
    
    if (currentState is MapSearchLoaded) {
      emit(MapSearchRefreshing(
        userLocation: userLocation,
        currentPosts: currentState.housingPostsWithDistance,
      ));
    } else if (currentState is MapSearchNoResults) {
      emit(MapSearchLoadingPosts(
        userLocation: userLocation,
        message: "Searching for accommodations...",
      ));
    }
    
    await loadHousingPostsWithDistance(userLocation);
  }

  void retryLastAction() {
    final currentState = state;
    
    if (currentState is MapSearchError) {
      if (currentState.lastUserLocation != null) {
        loadHousingPostsWithDistance(currentState.lastUserLocation!);
      } else {
        getUserLocation();
      }
    } else if (currentState is MapSearchNoResults) {
      loadHousingPostsWithDistance(currentState.userLocation);
    }
  }

  void selectPost(String postId) {
    final currentState = state;
    if (currentState is MapSearchLoaded) {
      emit(currentState.copyWith(selectedPostId: postId));
    } else if (currentState is MapSearchRefreshing) {
      emit(MapSearchRefreshing(
        userLocation: currentState.userLocation,
        currentPosts: currentState.currentPosts,
        newSearchRadiusKm: currentState.newSearchRadiusKm,
        selectedPostId: postId,
      ));
    }
  }

  LatLng? get currentUserLocation {
    final currentState = state;
    
    if (currentState is MapSearchLoaded) {
      return currentState.userLocation;
    } else if (currentState is MapSearchNoResults) {
      return currentState.userLocation;
    } else if (currentState is MapSearchLoadingPosts) {
      return currentState.userLocation;
    }
    
    return null;
  }
}