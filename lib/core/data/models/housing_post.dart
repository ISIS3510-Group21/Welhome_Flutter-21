import 'package:cloud_firestore/cloud_firestore.dart';
import 'tag_housing_post.dart';
import 'ammenities.dart';
import 'dart:math';

class HousingPost {
  final String id;
  final Timestamp creationDate;
  final Timestamp updateAt;
  final Timestamp closureDate;
  final Timestamp statusChange;
  final String address;
  final double price;
  final double rating;
  final String title;
  final String status; 
  final String description;
  final Location location;
  final String thumbnail;
  final String host;
  final String reviews;
  final String bookingDates;
  final List<Picture> pictures;
  final List<TagHousingPost> tag;
  final List<Ammenities> ammenities;
  final List<RoomateProfile> roomateProfile;

  HousingPost({
    this.id = "",
    Timestamp? creationDate,
    Timestamp? updateAt,
    Timestamp? closureDate,
    Timestamp? statusChange,
    this.address = "",
    this.price = 0.0,
    this.rating = 0.0,
    this.status = "available",
    this.title = "No title",
    this.description = "",
    Location? location,
    this.thumbnail =
        "https://img.freepik.com/free-photo/beautiful-interior-shot-modern-house-with-white-relaxing-walls-furniture-technology_181624-3828.jpg?semt=ais_hybrid&w=740&q=80",
    this.host = "",
    this.reviews = "",
    this.bookingDates = "",
    this.pictures = const [],
    this.tag = const [],
    this.ammenities = const [],
    this.roomateProfile = const [],
  })  : creationDate = creationDate ?? Timestamp.now(),
        updateAt = updateAt ?? Timestamp.now(),
        closureDate = closureDate ?? Timestamp.now(),
        statusChange = statusChange ?? Timestamp.now(),
        location = location ?? Location();

  factory HousingPost.fromMap(Map<String, dynamic> data, {String? documentId}) {
    return HousingPost(
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
          ? Location.fromMap(data['location'])
          : Location(),
      thumbnail: data['thumbnail'] ?? "",
      host: data['host'] ?? "",
      reviews: data['reviews'] ?? "",
      bookingDates: data['bookingDates'] ?? "",
      pictures: (data['Pictures'] as List<dynamic>?)
              ?.map((e) => Picture.fromMap(e))
              .toList() ??
          [],
      tag: (data['tags'] as List<dynamic>?)
              ?.map((e) => TagHousingPost.fromMap(e))
              .toList() ??
          [],
      ammenities: (data['amenities'] as List<dynamic>?)
              ?.map((e) => Ammenities.fromMap(e))
              .toList() ??
          [],
      roomateProfile: (data['roomateProfile'] as List<dynamic>?)
            ?.map((e) => RoomateProfile.fromMap(e))
            .toList() ??
          [],
    );
  }

  HousingPost copyWith({
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
  Location? location,
  String? thumbnail,
  String? host,
  String? reviews,
  String? bookingDates,
  List<Picture>? pictures,
  List<TagHousingPost>? tag,
  List<Ammenities>? ammenities,
  List<RoomateProfile>? roomateProfile,
}) {
  return HousingPost(
    id: id ?? this.id,
    creationDate: creationDate ?? this.creationDate,
    updateAt: updateAt ?? this.updateAt,
    closureDate: closureDate ?? this.closureDate,
    statusChange: statusChange ?? this.statusChange,
    address: address ?? this.address,
    price: price ?? this.price,
    rating: rating ?? this.rating,
    status: status ?? this.status,
    title: title ?? this.title,
    description: description ?? this.description,
    location: location ?? this.location,
    thumbnail: thumbnail ?? this.thumbnail,
    host: host ?? this.host,
    reviews: reviews ?? this.reviews,
    bookingDates: bookingDates ?? this.bookingDates,
    pictures: pictures ?? this.pictures,
    tag: tag ?? this.tag,
    ammenities: ammenities ?? this.ammenities,
    roomateProfile: roomateProfile ?? this.roomateProfile,
  );
}

  get images => null;

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
      'location': location.toMap(),
      'thumbnail': thumbnail,
      'host': host,
      'reviews': reviews,
      'bookingDates': bookingDates,
      'pictures': pictures.map((e) => e.toMap()).toList(),
      'tags': tag.map((e) => e.toMap()).toList(),
      'amenities': ammenities.map((e) => e.toMap()).toList(),
      'roomateProfile': roomateProfile.map((e) => e.toMap()).toList(),
    };
  }
}

class Location {
  final double lat;
  final double lng;

  Location({this.lat = 0.0, this.lng = 0.0});

  factory Location.fromMap(Map<String, dynamic> data) {
    return Location(
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

class RoomateProfile {
  final String id;
  final String name;
  final String studentUserID;

  RoomateProfile({
    this.id = "",
    this.name = "",
    this.studentUserID = "",
  });

  factory RoomateProfile.fromMap(Map<String, dynamic> data) {
    return RoomateProfile(
      id: data['id'] ?? "",
      name: data['name'] ?? "",
      studentUserID: data['studentUserID'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'studentUserID': studentUserID,
    };
  }
}

class Picture {
  final String photoPath;
  final String name;

  Picture({
    this.photoPath = "",
    this.name = "",
  });

  factory Picture.fromMap(Map<String, dynamic> data) {
    return Picture(
      photoPath: data['photoPath'] ?? "",
      name: data['name'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photoPath': photoPath,
      'name': name,
    };
  }
}

class HousingPostWithDistance extends HousingPost {
  final double distanceInKm;

  HousingPostWithDistance({
    required HousingPost housingPost,
    required this.distanceInKm,
  }) : super(
          id: housingPost.id,
          creationDate: housingPost.creationDate,
          updateAt: housingPost.updateAt,
          closureDate: housingPost.closureDate,
          statusChange: housingPost.statusChange,
          address: housingPost.address,
          price: housingPost.price,
          rating: housingPost.rating,
          status: housingPost.status,
          title: housingPost.title,
          description: housingPost.description,
          location: housingPost.location,
          thumbnail: housingPost.thumbnail,
          host: housingPost.host,
          reviews: housingPost.reviews,
          bookingDates: housingPost.bookingDates,
          pictures: housingPost.pictures,
          tag: housingPost.tag,
          ammenities: housingPost.ammenities,
          roomateProfile: housingPost.roomateProfile,
        );

  factory HousingPostWithDistance.fromHousingPost(
    HousingPost housingPost,
    double userLat,
    double userLng,
  ) {
    final distanceInKm = _calculateDistance(
      userLat,
      userLng,
      housingPost.location.lat,
      housingPost.location.lng,
    );

    return HousingPostWithDistance(
      housingPost: housingPost,
      distanceInKm: distanceInKm,
    );
  }

  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const int earthRadius = 6371; // Radio de la Tierra en kilómetros

    double lat1Rad = lat1 * pi / 180;
    double lat2Rad = lat2 * pi / 180;
    double deltaLatRad = (lat2 - lat1) * pi / 180;
    double deltaLngRad = (lng2 - lng1) * pi / 180;

    double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
            sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  String get formattedDistance {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

}
