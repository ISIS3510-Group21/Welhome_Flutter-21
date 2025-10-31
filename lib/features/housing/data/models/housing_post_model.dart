import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/housing/data/models/reviews_model.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/housing/data/models/amenity_model.dart';
import 'package:welhome/features/housing/data/models/tag_housing_post_model.dart';
import 'location_model.dart';
import 'picture_model.dart';
import 'roomate_profile_model.dart';

class HousingPostModel extends HousingPostEntity {

  final Timestamp closureDate;
  final Timestamp statusChange;
  final String? reviewsPath;

  HousingPostModel({
    required String id,
    required Timestamp creationDate,
    required Timestamp updateAt,
    Timestamp? closureDate,
    Timestamp? statusChange,
    String address = "",
    double price = 0.0,
    double rating = 0.0,
    String bookingDates = "",
    String status = "available",
    String title = "No title", 
    String description = "",
    LocationModel? location,
    String thumbnail =
        "https://img.freepik.com/free-photo/beautiful-interior-shot-modern-house-with-white-relaxing-walls-furniture-technology_181624-3828.jpg?semt=ais_hybrid&w=740&q=80",
    String host = "",
    ReviewsModel? reviews, // Puede ser nulo inicialmente
    this.reviewsPath,
    List<PictureModel> pictures = const [],
    List<TagHousingPostModel> tag = const [],
    List<AmenityModel> ammenities = const [],
    List<RoomateProfileModel> roomateProfile = const [],

  })  :
        closureDate = closureDate ?? Timestamp.now(),
        statusChange = statusChange ?? Timestamp.now(),
        super(
            id: id,
            creationDate: (creationDate).toDate(),
            updateAt: (updateAt).toDate(),
            address: address,
            price: price,
            rating: rating,
            reviews: reviews ?? const ReviewsModel(id: '', rating: 0.0, reviewQuantity: 0),
            title: title,
            status: status,
            description: description,
            location: location ?? const LocationModel(),
            thumbnail: thumbnail,
            host: host,
            bookingDates: bookingDates,
            pictures: pictures,
            tags: tag,
            amenities: ammenities,
            roomateProfile: roomateProfile);

  factory HousingPostModel.fromMap(Map<String, dynamic> data, {String? documentId}) {
    return HousingPostModel(
      id: documentId ?? data['id'] ?? "",
      creationDate: data['creationDate'] ?? Timestamp.now(),
      updateAt: data['updateAt'] ?? Timestamp.now(),
      closureDate: data['closureDate'] ?? Timestamp.now(),
      statusChange: data['statusChange'] ?? Timestamp.now(),
      address: data['address'] ?? "",
      price: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      status: data['status'] ?? "available",
      title: data['title'] ?? "No title",
      description: data['description'] ?? "",
      location: data['location'] != null
          ? LocationModel.fromMap(data['location'])
          : const LocationModel(),
      thumbnail: data['thumbnail'] ?? "",
      host: data['host'] ?? "",
      reviewsPath: data['reviews'] as String?,
      bookingDates: data['bookingDates'] ?? "",
      pictures: (data['Pictures'] as List<dynamic>?)
              ?.map((e) => PictureModel.fromMap(e))
              .toList() ??
          [],
      tag: (data['tags'] as List<dynamic>?)
              ?.map((e) => TagHousingPostModel.fromMap(e))
              .toList() ??
          [],
      ammenities: (data['amenities'] as List<dynamic>?)
              ?.map((e) => AmenityModel.fromMap(e))
              .toList() ??
          [],
      roomateProfile: (data['roomateProfile'] as List<dynamic>?)
            ?.map((e) => RoomateProfileModel.fromMap(e))
            .toList() ??
          [],
    );
  }

  HousingPostModel copyWith({
  String? id,
  Timestamp? creationDate,
  Timestamp? updateAt,
  Timestamp? closureDate,
  Timestamp? statusChange,
  String? address,
  double? price,
  double? rating,
  String? status,
  String? title,
  String? description,
  LocationModel? location,
  String? thumbnail,
  String? host,
  ReviewsModel? reviews,
  String? reviewsPath,
  String? bookingDates,
  List<PictureModel>? pictures,
  List<TagHousingPostModel>? tag,
  List<AmenityModel>? ammenities,
  List<RoomateProfileModel>? roomateProfile,
}) {
  return HousingPostModel(
    id: id ?? this.id,
    creationDate: creationDate ?? Timestamp.fromDate(super.creationDate),
    updateAt: updateAt ?? Timestamp.fromDate(super.updateAt),
    closureDate: closureDate ?? this.closureDate,
    statusChange: statusChange ?? this.statusChange,
    address: address ?? this.address,
    price: price ?? this.price,
    rating: rating ?? this.rating,
    status: status ?? this.status,
    title: title ?? this.title, 
    description: description ?? this.description,
    location: location ?? (this.location as LocationModel),
    thumbnail: thumbnail ?? this.thumbnail,
    host: host ?? this.host, 
    reviews: reviews ?? (this.reviews as ReviewsModel?),
    reviewsPath: reviewsPath ?? this.reviewsPath,
    bookingDates: bookingDates ?? this.bookingDates,
    pictures: pictures ?? (this.pictures as List<PictureModel>),
    tag: tag ?? this.tags as List<TagHousingPostModel>,
    ammenities: ammenities ?? this.amenities as List<AmenityModel>,
    roomateProfile: roomateProfile ?? this.roomateProfile as List<RoomateProfileModel>,
  );
}

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creationDate': creationDate,
      'updateAt': updateAt,
      'closureDate': closureDate,
      'statusChange': statusChange,
      'address': address,
      'price': price,
      'rating': rating,
      'status': status,
      'title': title,
      'description': description,
      'location': (location as LocationModel).toMap(),
      'thumbnail': thumbnail,
      'host': host,
      'reviews': (reviews as ReviewsModel).toMap(),
      'bookingDates': bookingDates,
      'pictures': pictures.map((e) => (e as PictureModel).toMap()).toList(),
      'tag': tags.map((e) => (e as TagHousingPostModel).toMap()).toList(),
      'ammenities': amenities.map((e) => (e as AmenityModel).toMap()).toList(),
      'roomateProfile': roomateProfile.map((e) => (e as RoomateProfileModel).toMap()).toList(),
    };
  }
}
