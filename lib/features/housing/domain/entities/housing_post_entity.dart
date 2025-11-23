import 'package:equatable/equatable.dart';
import 'package:welhome/features/housing/domain/entities/reviews_entity.dart';
import 'package:welhome/features/housing/domain/entities/amenity_entity.dart';
import 'package:welhome/features/housing/domain/entities/location_entity.dart';
import 'package:welhome/features/housing/domain/entities/picture_entity.dart';
import 'package:welhome/features/housing/domain/entities/roomate_profile_entity.dart';
import 'package:welhome/features/housing/domain/entities/tag_housing_post_entity.dart';

class HousingPostEntity extends Equatable {
  final String id;
  final DateTime creationDate;
  final DateTime updateAt;
  final String address;
  final double price;
  final double rating;
  final ReviewsEntity reviews;
  final String title;
  final String status; 
  final String description;
  final LocationEntity location;
  final String thumbnail;
  final String host;
  final String bookingDates;
  final List<PictureEntity> pictures;
  final List<TagHousingPostEntity> tags;
  final List<AmenityEntity> amenities;
  final List<RoomateProfileEntity> roomateProfile;

  const HousingPostEntity({
    required this.id,
    required this.creationDate,
    required this.updateAt,
    required this.address,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.title,
    required this.status,
    required this.description,
    required this.location,
    required this.thumbnail,
    required this.host,
    required this.bookingDates,
    required this.pictures,
    required this.tags,
    required this.amenities,
    required this.roomateProfile,
  });

  @override
  List<Object?> get props => [
    id, 
    creationDate, 
    updateAt, 
    address, 
    price, 
    rating, 
    reviews, 
    title, 
    status, 
    description, 
    location, 
    thumbnail, 
    host, 
    bookingDates, 
    pictures, 
    tags, 
    amenities, 
    roomateProfile
  ];
}