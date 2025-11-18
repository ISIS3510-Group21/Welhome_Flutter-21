import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import '../cubit/map_search_cubit.dart';

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
    if (state is MapSearchLoading || state is MapSearchInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MapSearchError) {
      return Center(child: Text(state.message));
    }

    if (state is MapSearchLoaded) {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(state.properties.first.location.lat, state.properties.first.location.lng),
          zoom: 12,
        ),
        markers: _createMarkers(context, state.properties, state.selectedProperty?.id),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      );
    }

    return const Center(child: Text("Preparing map..."));
  }

  Set<Marker> _createMarkers(
    BuildContext context,
    List<HousingPostEntity> properties,
    String? selectedPostId,
  ) {
    final Set<Marker> markers = {};

    for (var post in properties) {
      final position = LatLng(
        post.location.lat,
        post.location.lng,
      );

      final bool isSelected = selectedPostId != null && selectedPostId == post.id;

      markers.add(
        Marker(
          markerId: MarkerId("housing_${post.id}"),
          position: position,
          infoWindow: InfoWindow(title: post.title),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
          ),
          onTap: () => context.read<MapSearchCubit>().selectProperty(post),
        ),
      );
    }
    return markers;
  }
}