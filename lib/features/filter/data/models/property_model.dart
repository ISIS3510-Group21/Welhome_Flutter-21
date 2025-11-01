import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/filter/domain/entities/property.dart';

class PropertyModel extends Property {
  PropertyModel({
    required super.id,
    required super.title,
    required super.description,
    required super.address,
    required super.price,
    required super.rating,
    required super.creationDate,
    required super.updatedAt,
    required super.location,
    required super.host,
    super.closureDate,
    super.amenities,
    super.housingTags,
    super.pictures,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic price) {
      if (price == null) return 0.0;
      if (price is num) return price.toDouble();
      if (price is String) {
        final numericString = price.replaceAll(RegExp(r'[^0-9.]'), '');
        return double.tryParse(numericString) ?? 0.0;
      }
      return 0.0;
    }

    return PropertyModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'No Title',
      description: json['description']?.toString() ?? 'No Description',
      address: json['address']?.toString() ?? 'No Address',
      price: parsePrice(json['price']),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
    creationDate: json['creationDate'] is Timestamp
      ? (json['creationDate'] as Timestamp).toDate()
      : (json['creationDate'] is int
        ? DateTime.fromMillisecondsSinceEpoch(json['creationDate'] as int)
        : (json['creationDate'] is String
          ? DateTime.tryParse(json['creationDate'] as String) ?? DateTime.now()
          : DateTime.now())),
    closureDate: json['closureDate'] is Timestamp
      ? (json['closureDate'] as Timestamp).toDate()
      : (json['closureDate'] is int
        ? DateTime.fromMillisecondsSinceEpoch(json['closureDate'] as int)
        : (json['closureDate'] is String
          ? DateTime.tryParse(json['closureDate'] as String)
          : null)),
    updatedAt: json['updatedAt'] is Timestamp
      ? (json['updatedAt'] as Timestamp).toDate()
      : (json['updatedAt'] is int
        ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
        : (json['updatedAt'] is String
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now())),
      location: (json['location'] is Map)
          ? {
              'lat': (json['location'] as Map)['lat']?.toDouble() ?? 0.0,
              'lng': (json['location'] as Map)['lng']?.toDouble() ?? 0.0,
            }
          : {'lat': 0.0, 'lng': 0.0},
      host: json['host'] is DocumentReference 
          ? (json['host'] as DocumentReference).id
          : json['host']?.toString() ?? 'No Host',
      amenities: (json['amenities'] as List<dynamic>?)?.cast<String>() ?? [],
      housingTags: (json['housingTags'] as List<dynamic>?)?.cast<String>() ?? [],
      pictures: (json['pictures'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'address': address,
      'price': price,
      'rating': rating,
      // Store dates as ISO8601 strings so they are JSON encodable
      'creationDate': creationDate.toIso8601String(),
      'closureDate': closureDate?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'location': location,
      'host': host,
      'amenities': amenities,
      'housingTags': housingTags,
      'pictures': pictures,
    };
  }

  Property toDomain() => this;
}