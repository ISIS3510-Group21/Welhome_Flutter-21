class Ammenities {
  final String id;
  final String name;
  final String iconPath;

  Ammenities({
    this.id = '',
    this.name = '',
    this.iconPath = '',
  });

  factory Ammenities.fromMap(Map<String, dynamic> data, {String? documentId}) {
    return Ammenities(
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
