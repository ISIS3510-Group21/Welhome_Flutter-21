import 'package:equatable/equatable.dart';
import 'package:welhome/features/housing/domain/entities/location_entity.dart';

class HousingPostWithDistanceEntity extends Equatable {
  final String id;
  final String title;
  final double price;
  final double rating;
  final String? thumbnail;
  final LocationEntity location;
  final String address;
  final double distanceInKm;
  final String formattedDistance;

  const HousingPostWithDistanceEntity({
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

  @override
  List<Object?> get props => [
    id,
    title,
    price,
    rating,
    thumbnail,
    location,
    address,
    distanceInKm,
    formattedDistance,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is HousingPostWithDistanceEntity &&
        other.id == id &&
        other.title == title &&
        other.price == price &&
        other.rating == rating &&
        other.thumbnail == thumbnail &&
        other.location == location &&
        other.address == address &&
        other.distanceInKm == distanceInKm &&
        other.formattedDistance == formattedDistance;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      price,
      rating,
      thumbnail,
      location,
      address,
      distanceInKm,
      formattedDistance,
    );
  }

  HousingPostWithDistanceEntity copyWith({
    String? id,
    String? title,
    double? price,
    double? rating,
    String? thumbnail,
    LocationEntity? location,
    String? address,
    double? distanceInKm,
    String? formattedDistance,
  }) {
    return HousingPostWithDistanceEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      thumbnail: thumbnail ?? this.thumbnail,
      location: location ?? this.location,
      address: address ?? this.address,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      formattedDistance: formattedDistance ?? this.formattedDistance,
    );
  }

  @override
  String toString() {
    return 'HousingPostWithDistanceEntity(id: $id, title: $title, price: $price, rating: $rating, thumbnail: $thumbnail, location: $location, address: $address, distanceInKm: $distanceInKm, formattedDistance: $formattedDistance)';
  }
}