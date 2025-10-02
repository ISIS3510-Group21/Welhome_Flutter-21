import 'package:cloud_firestore/cloud_firestore.dart';

class HousingPreview {
  final String id;
  final double price;
  final double rating;
  final String title;
  final String photoPath;
  final DocumentReference? housing;

  HousingPreview({
    this.id = '',
    this.price = 0.0,
    this.rating = 0.0,
    this.title = '',
    this.photoPath = '',
    this.housing,
  });

  factory HousingPreview.fromMap(Map<String, dynamic> data, {String? documentId}) {
    return HousingPreview(
      id: documentId ?? data['id'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      title: data['title'] ?? '',
      photoPath: data['photoPath'] ?? '',
      housing: data['housing'] as DocumentReference?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'rating': rating,
      'title': title,
      'photoPath': photoPath,
      'housing': housing,
    };
  }
}
