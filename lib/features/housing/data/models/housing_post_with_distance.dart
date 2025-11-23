import 'package:welhome/features/housing/data/models/location_model.dart';

class HousingPostWithDistance {
  final String id;
  final String title;
  final double price;
  final double rating;
  final String? thumbnail;
  final LocationModel location;
  final String address;
  final double distanceInKm;
  final String formattedDistance;

  HousingPostWithDistance({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    this.thumbnail,
    required this.location,
    required this.address,
    required this.distanceInKm,
    required this.formattedDistance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'rating': rating,
      'thumbnail': thumbnail,
      'location': location.toMap(),
      'address': address,
      'distanceInKm': distanceInKm,
      'formattedDistance': formattedDistance,
    };
  }
}