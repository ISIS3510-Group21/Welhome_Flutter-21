import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/features/housing/domain/entities/location_entity.dart';

class HousingDetailLocationMap extends StatelessWidget {
  final LocationEntity location;
  final String address;

  const HousingDetailLocationMap({super.key, required this.location, required this.address});

  @override
  Widget build(BuildContext context) {
    final LatLng propertyLatLng = LatLng(location.lat, location.lng);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: AppTextStyles.tittleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            address,
            style: AppTextStyles.textNormalGrey,
          ),
          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 212,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: propertyLatLng,
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("property_marker"),
                    position: propertyLatLng,
                  ),
                },
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
