class RoomieTag {
  final String id;
  final String name;
  final String iconPath;

  RoomieTag({
    this.id = '',
    this.name = '',
    this.iconPath = '',
  });

  factory RoomieTag.fromMap(Map<String, dynamic> data, {String? documentId}) {
    return RoomieTag(
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
