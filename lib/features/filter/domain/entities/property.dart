import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  static final RegExp numericRegex = RegExp(r'[^0-9.]');
  final String id;
  final String title;
  final String description;
  final String address;
  final double price;
  final double rating;
  final DateTime creationDate;
  final DateTime? closureDate;
  final DateTime updatedAt;
  final Map<String, double> location;
  final String host;
  List<String> amenities = [];
  List<String> housingTags = [];
  List<String> pictures = [];

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.price,
    required this.rating,
    required this.creationDate,
    required this.updatedAt,
    required this.location,
    required this.host,
    this.closureDate,
    this.amenities = const [],
    this.housingTags = const [],
    this.pictures = const [],
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    try {
      // Procesar el precio: remover caracteres no numéricos y convertir a double
      double parsePrice(dynamic price) {
        if (price == null) return 0.0;
        if (price is num) return price.toDouble();
        if (price is String) {
          final numericString = price.replaceAll(numericRegex, '');
          return double.tryParse(numericString) ?? 0.0;
        }
        return 0.0;
      }

      return Property(
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
    } catch (e) {
      print('Error parsing property: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}