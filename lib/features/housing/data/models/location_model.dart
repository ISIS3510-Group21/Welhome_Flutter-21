import 'package:welhome/features/housing/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({super.lat = 0.0, super.lng = 0.0});

  factory LocationModel.fromMap(Map<String, dynamic> data) {
    return LocationModel(
      lat: (data['lat'] ?? 0).toDouble(),
      lng: (data['lng'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}