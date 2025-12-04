import 'package:equatable/equatable.dart';

class FavoriteItem extends Equatable {
  final String postId;
  final String title;
  final String address;
  final double price;
  final double rating;
  final int reviewQuantity;
  final String? thumbnailUrl;
  final String? hostId;

  // Sync metadata
  final DateTime addedAt;
  final DateTime lastModifiedAt;
  final bool pendingSync; // true si el cambio aún no se sincronizó
  final String? syncError; // error al intentar sincronizar

  const FavoriteItem({
    required this.postId,
    required this.title,
    required this.address,
    required this.price,
    required this.rating,
    required this.reviewQuantity,
    this.thumbnailUrl,
    this.hostId,
    required this.addedAt,
    required this.lastModifiedAt,
    this.pendingSync = false,
    this.syncError,
  });

  @override
  List<Object?> get props => [
        postId,
        title,
        address,
        price,
        rating,
        reviewQuantity,
        thumbnailUrl,
        hostId,
        addedAt,
        lastModifiedAt,
        pendingSync,
        syncError,
      ];

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'title': title,
      'address': address,
      'price': price,
      'rating': rating,
      'reviewQuantity': reviewQuantity,
      'thumbnailUrl': thumbnailUrl,
      'hostId': hostId,
      'addedAt': addedAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
      'pendingSync': pendingSync,
      'syncError': syncError,
    };
  }

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      postId: map['postId'] as String,
      title: map['title'] as String,
      address: map['address'] as String,
      price: (map['price'] as num).toDouble(),
      rating: (map['rating'] as num).toDouble(),
      reviewQuantity: map['reviewQuantity'] as int,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      hostId: map['hostId'] as String?,
      addedAt: DateTime.parse(map['addedAt'] as String),
      lastModifiedAt: DateTime.parse(map['lastModifiedAt'] as String),
      pendingSync: map['pendingSync'] as bool? ?? false,
      syncError: map['syncError'] as String?,
    );
  }

  FavoriteItem copyWith({
    String? postId,
    String? title,
    String? address,
    double? price,
    double? rating,
    int? reviewQuantity,
    String? thumbnailUrl,
    String? hostId,
    DateTime? addedAt,
    DateTime? lastModifiedAt,
    bool? pendingSync,
    String? syncError,
  }) {
    return FavoriteItem(
      postId: postId ?? this.postId,
      title: title ?? this.title,
      address: address ?? this.address,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewQuantity: reviewQuantity ?? this.reviewQuantity,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      hostId: hostId ?? this.hostId,
      addedAt: addedAt ?? this.addedAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      syncError: syncError ?? this.syncError,
    );
  }
}
