import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/filter/domain/entities/property.dart';

class PropertyModel extends Property {
  PropertyModel({
    required String id,
    required String title,
    required String description,
    required String address,
    required double price,
    required double rating,
    required DateTime creationDate,
    required DateTime updatedAt,
    required Map<String, double> location,
    required String host,
    DateTime? closureDate,
    List<String> amenities = const [],
    List<String> housingTags = const [],
    List<String> pictures = const [],
  }) : super(
          id: id,
          title: title,
          description: description,
          address: address,
          price: price,
          rating: rating,
          creationDate: creationDate,
          updatedAt: updatedAt,
          location: location,
          host: host,
          closureDate: closureDate,
          amenities: amenities,
          housingTags: housingTags,
          pictures: pictures,
        );

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
          : DateTime.now(),
      closureDate: json['closureDate'] is Timestamp
          ? (json['closureDate'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      location: (json['location'] is Map)
          ? {
              'lat': (json['location'] as Map)['lat']?.toDouble() ?? 0.0,
              'lng': (json['location'] as Map)['lng']?.toDouble() ?? 0.0,
            }
          : {'lat': 0.0, 'lng': 0.0},
      host: json['host']?.toString() ?? 'No Host',
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
      'creationDate': creationDate,
      'closureDate': closureDate,
      'updatedAt': updatedAt,
      'location': location,
      'host': host,
      'amenities': amenities,
      'housingTags': housingTags,
      'pictures': pictures,
    };
  }

  Property toDomain() => this;
}