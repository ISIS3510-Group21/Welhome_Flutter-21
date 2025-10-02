import 'package:cloud_firestore/cloud_firestore.dart';
import 'tag_housing_post.dart';
import 'amenities.dart';

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
  final List<Amenities> amenities;
  final RoommateProfile roommateProfile;

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
    this.amenities = const [],
    RoommateProfile? roommateProfile,
  })  : creationDate = creationDate ?? Timestamp.now(),
        updateAt = updateAt ?? Timestamp.now(),
        closureDate = closureDate ?? Timestamp.now(),
        statusChange = statusChange ?? Timestamp.now(),
        location = location ?? Location(),
        roommateProfile = roommateProfile ?? RoommateProfile();

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
      tag: (data['Tag'] as List<dynamic>?)
              ?.map((e) => TagHousingPost.fromMap(e))
              .toList() ??
          [],
      amenities: (data['Ammenities'] as List<dynamic>?)
              ?.map((e) => Amenities.fromMap(e))
              .toList() ??
          [],
      roommateProfile: data['RoomateProfile'] != null
          ? RoommateProfile.fromMap(data['RoomateProfile'])
          : RoommateProfile(),
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
      'location': location.toMap(),
      'thumbnail': thumbnail,
      'host': host,
      'reviews': reviews,
      'bookingDates': bookingDates,
      'Pictures': pictures.map((e) => e.toMap()).toList(),
      'Tag': tag.map((e) => e.toMap()).toList(),
      'Ammenities': amenities.map((e) => e.toMap()).toList(),
      'RoomateProfile': roommateProfile.toMap(),
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

class RoommateProfile {
  final String id;
  final String name;
  final String studentUserID;

  RoommateProfile({
    this.id = "",
    this.name = "",
    this.studentUserID = "",
  });

  factory RoommateProfile.fromMap(Map<String, dynamic> data) {
    return RoommateProfile(
      id: data['id'] ?? "",
      name: data['name'] ?? "",
      studentUserID: data['StudentUserID'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'StudentUserID': studentUserID,
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
      photoPath: data['PhotoPath'] ?? "",
      name: data['name'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'PhotoPath': photoPath,
      'name': name,
    };
  }
}
