class Tag {
  final String id;
  final String name;
  final String iconPath;

  Tag({
    required this.id,
    required this.name,
    required this.iconPath,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      iconPath: json['iconPath'] as String,
    );
  }
}