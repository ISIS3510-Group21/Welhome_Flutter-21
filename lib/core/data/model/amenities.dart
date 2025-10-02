class Amenities {
  final String id;
  final String name;
  final String iconPath;

  Amenities({
    this.id = '',
    this.name = '',
    this.iconPath = '',
  });

  factory Amenities.fromMap(Map<String, dynamic> data, {String? documentId}) {
    return Amenities(
      id: documentId ?? data['id'] ?? '',
      name: data['name'] ?? '',
      iconPath: data['iconPath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
    };
  }
}
