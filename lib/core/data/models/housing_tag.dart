import 'housing_preview.dart';

class HousingTag {
  final String id;
  final String name;
  final String iconPath;
  final List<HousingPreview> housingPreview;

  HousingTag({
    this.id = "",
    this.name = "",
    this.iconPath = "",
    this.housingPreview = const [],
  });

  factory HousingTag.fromMap(Map<String, dynamic> data, {String? documentId}) {
    return HousingTag(
      id: documentId ?? data['id'] ?? "",
      name: data['name'] ?? "",
      iconPath: data['iconPath'] ?? "",
      housingPreview: (data['housingPreview'] as List<dynamic>?)
              ?.map((e) => HousingPreview.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'housingPreview': housingPreview.map((e) => e.toMap()).toList(),
    };
  }
}
