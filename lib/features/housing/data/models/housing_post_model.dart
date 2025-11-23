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
    required super.id,
    required Timestamp creationDate,
    required Timestamp updateAt,
    Timestamp? closureDate,
    Timestamp? statusChange,
    super.address = "",
    super.price = 0.0,
    super.rating = 0.0,
    super.bookingDates = "",
    super.status = "available",
    super.title = "No title", 
    super.description = "",
    LocationModel? location,
    super.thumbnail = "https://img.freepik.com/free-photo/beautiful-interior-shot-modern-house-with-white-relaxing-walls-furniture-technology_181624-3828.jpg?semt=ais_hybrid&w=740&q=80",
    super.host = "",
    ReviewsModel? reviews,
    this.reviewsPath,
    List<PictureModel> super.pictures = const [],
    List<TagHousingPostModel> tag = const [],
    List<AmenityModel> ammenities = const [],
    List<RoomateProfileModel> super.roomateProfile = const [],
  })  : closureDate = closureDate ?? Timestamp.now(),
        statusChange = statusChange ?? Timestamp.now(),
        super(
          creationDate: creationDate.toDate(),
          updateAt: updateAt.toDate(),
          reviews: reviews ?? const ReviewsModel(id: '', rating: 0.0, reviewQuantity: 0),
          location: location ?? const LocationModel(),
          tags: tag,
          amenities: ammenities,
        );

  factory HousingPostModel.fromMap(Map<String, dynamic> data, {String? documentId}) {
    // Helper functions como en Kotlin
    String? coerceDocPath(dynamic raw) {
      if (raw == null) return null;
      if (raw is String) return raw;
      if (raw is DocumentReference) return raw.path;
      return raw.toString();
    }

    String coerceString(dynamic raw, [String defaultValue = '']) {
      if (raw == null) return defaultValue;
      if (raw is String) return raw;
      if (raw is DocumentReference) return raw.path;
      return raw.toString();
    }

    LocationModel? coerceLocation(dynamic raw) {
      if (raw == null) return null;
      if (raw is Map<String, dynamic>) {
        return LocationModel.fromMap(raw);
      }
      return const LocationModel();
    }

    // Aplicar coerción a todos los campos string
    final hostString = coerceString(data['host']);
    final addressString = coerceString(data['address']);
    final titleString = coerceString(data['title'], 'No title');
    final descriptionString = coerceString(data['description']);
    final thumbnailString = coerceString(data['thumbnail']);
    final statusString = coerceString(data['status'], 'available');
    final bookingDatesString = coerceString(data['bookingDates']);

    // Reviews - seguir el mismo patrón que Kotlin (siempre como string)
    final reviewsPathString = coerceDocPath(data['reviews']);

    return HousingPostModel(
      id: documentId ?? coerceString(data['id']),
      creationDate: data['creationDate'] ?? Timestamp.now(),
      updateAt: data['updateAt'] ?? Timestamp.now(),
      closureDate: data['closureDate'] ?? Timestamp.now(),
      statusChange: data['statusChange'] ?? Timestamp.now(),
      address: addressString,
      price: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      status: statusString,
      title: titleString,
      description: descriptionString,
      location: coerceLocation(data['location']),
      thumbnail: thumbnailString,
      host: hostString,
      reviewsPath: reviewsPathString,
      bookingDates: bookingDatesString,
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
      description: description ?? super.description,
      location: location ?? (super.location as LocationModel),
      thumbnail: thumbnail ?? super.thumbnail,
      host: host ?? super.host,
      reviews: reviews ?? this.reviews as ReviewsModel,
      reviewsPath: reviewsPath ?? this.reviewsPath,
      bookingDates: bookingDates ?? this.bookingDates,
      pictures: pictures ?? (this.pictures as List<PictureModel>),
      tag: tag ?? tags as List<TagHousingPostModel>,
      ammenities: ammenities ?? amenities as List<AmenityModel>,
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
      'reviews': reviewsPath, // Usar reviewsPath en lugar de reviewsReference
      'bookingDates': bookingDates,
      'pictures': pictures.map((e) => (e as PictureModel).toMap()).toList(),
      'tag': tags.map((e) => (e as TagHousingPostModel).toMap()).toList(),
      'ammenities': amenities.map((e) => (e as AmenityModel).toMap()).toList(),
      'roomateProfile': roomateProfile.map((e) => (e as RoomateProfileModel).toMap()).toList(),
    };
  }
}