import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:welhome/core/data/models/housing_post.dart';
import '../cubit/map_search_cubit.dart';
import '../cubit/map_search_state.dart';
import 'loading_state_widget.dart';
import 'error_state_widget.dart';

class MapSectionWidget extends StatelessWidget {
  const MapSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapSearchCubit, MapSearchState>(
      builder: (context, state) {
        return SizedBox(
          height: 325,
          width: double.infinity,
          child: _buildMapContent(context, state),
        );
      },
    );
  }

  Widget _buildMapContent(BuildContext context, MapSearchState state) {
    if (state is MapSearchLoadingLocation) {
      return const LoadingStateWidget(message: "Getting your location...");
    }

    if (state is MapSearchError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: state.canRetry
            ? () => context.read<MapSearchCubit>().retryLastAction()
            : () {},
      );
    }

    if (state is MapSearchNoResults) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No accommodations in this area',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (state is MapSearchLoadingPosts || 
        state is MapSearchLoaded || 
        state is MapSearchRefreshing) {
      LatLng userLocation;
      List<HousingPostWithDistance> housingPostsWithDistance = [];

      if (state is MapSearchLoadingPosts) {
        userLocation = state.userLocation;
      } else if (state is MapSearchLoaded) {
        userLocation = state.userLocation;
        housingPostsWithDistance = state.housingPostsWithDistance;
      } else if (state is MapSearchRefreshing) {
        userLocation = state.userLocation;
        housingPostsWithDistance = state.currentPosts;
      } else {
        return const LoadingStateWidget(message: "Loading map...");
      }

      final String? selectedPostId = (state is MapSearchLoaded)
          ? state.selectedPostId
          : (state is MapSearchRefreshing)
              ? state.selectedPostId
              : null;

      return Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userLocation,
              zoom: 14,
            ),
            markers: _createMarkers(
              context,
              userLocation,
              housingPostsWithDistance,
              selectedPostId,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          // Loading indicator for refreshing state
          if (state is MapSearchRefreshing)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const LinearProgressIndicator(),
              ),
            ),
        ],
      );
    }

    // Initial state
    return const LoadingStateWidget(message: "Preparing map...");
  }

  Set<Marker> _createMarkers(
    BuildContext context,
    LatLng userLocation,
    List<HousingPostWithDistance> housingPostsWithDistance,
    String? selectedPostId,
  ) {
    final Set<Marker> markers = {};

    // User location marker (only show if we have posts or we're not in loading state)
    markers.add(
      Marker(
        markerId: const MarkerId("user_location"),
        position: userLocation,
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Housing post markers
    for (var postWithDistance in housingPostsWithDistance) {
      final position = LatLng(
        postWithDistance.location.lat,
        postWithDistance.location.lng,
      );

      final bool isSelected = selectedPostId != null && selectedPostId == postWithDistance.id;

      markers.add(
        Marker(
          markerId: MarkerId("housing_${postWithDistance.id}"),
          position: position,
          infoWindow: InfoWindow(
            title: postWithDistance.title,
            snippet: "\$${postWithDistance.price.toInt()}/month • ${postWithDistance.formattedDistance} away",
            onTap: () {
              // Trigger selection when tapping info window as well
              context.read<MapSearchCubit>().selectPost(postWithDistance.id);
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
          ),
          onTap: () {
            context.read<MapSearchCubit>().selectPost(postWithDistance.id);
          },
        ),
      );
    }

    return markers;
  }
}