import 'package:equatable/equatable.dart';

/// Modelo para representar un post de vivienda en borrador
class DraftPost extends Equatable {
  final String id; // ID único del borrador
  final String title;
  final String description;
  final String address;
  final double price;
  final String? housingTagId;
  final List<String> amenityIds;
  final List<String> localImagePaths; // Rutas locales de imágenes
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final bool isSyncing; // Está siendo enviado a Firebase
  final bool isSynced; // Fue enviado exitosamente
  final String? syncError; // Error de sincronización (si existe)
  final String? remotePostId; // ID del post en Firebase (si fue sincronizado)

  const DraftPost({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.price,
    this.housingTagId,
    this.amenityIds = const [],
    this.localImagePaths = const [],
    required this.createdAt,
    required this.lastModifiedAt,
    this.isSyncing = false,
    this.isSynced = false,
    this.syncError,
    this.remotePostId,
  });

  /// Convierte a Map para almacenar en SharedPreferences/JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'address': address,
      'price': price,
      'housingTagId': housingTagId,
      'amenityIds': amenityIds,
      'localImagePaths': localImagePaths,
      'createdAt': createdAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
      'isSyncing': isSyncing,
      'isSynced': isSynced,
      'syncError': syncError,
      'remotePostId': remotePostId,
    };
  }

  /// Crea una instancia desde un Map
  factory DraftPost.fromMap(Map<String, dynamic> map) {
    return DraftPost(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      address: map['address'] as String,
      price: (map['price'] as num).toDouble(),
      housingTagId: map['housingTagId'] as String?,
      amenityIds: List<String>.from(map['amenityIds'] as List? ?? []),
      localImagePaths: List<String>.from(map['localImagePaths'] as List? ?? []),
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastModifiedAt: DateTime.parse(map['lastModifiedAt'] as String),
      isSyncing: map['isSyncing'] as bool? ?? false,
      isSynced: map['isSynced'] as bool? ?? false,
      syncError: map['syncError'] as String?,
      remotePostId: map['remotePostId'] as String?,
    );
  }

  /// Crea una copia con campos modificados
  DraftPost copyWith({
    String? id,
    String? title,
    String? description,
    String? address,
    double? price,
    String? housingTagId,
    List<String>? amenityIds,
    List<String>? localImagePaths,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    bool? isSyncing,
    bool? isSynced,
    String? syncError,
    String? remotePostId,
  }) {
    return DraftPost(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      price: price ?? this.price,
      housingTagId: housingTagId ?? this.housingTagId,
      amenityIds: amenityIds ?? this.amenityIds,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      isSyncing: isSyncing ?? this.isSyncing,
      isSynced: isSynced ?? this.isSynced,
      syncError: syncError ?? this.syncError,
      remotePostId: remotePostId ?? this.remotePostId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        address,
        price,
        housingTagId,
        amenityIds,
        localImagePaths,
        createdAt,
        lastModifiedAt,
        isSyncing,
        isSynced,
        syncError,
        remotePostId,
      ];
}
