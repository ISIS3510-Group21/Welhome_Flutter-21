import 'package:cloud_firestore/cloud_firestore.dart';

class TagHousingPost {
  final String id;
  final String name;
  final DocumentReference? housingTag;

  TagHousingPost({
    this.id = '',
    this.name = '',
    this.housingTag,
  });

  factory TagHousingPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TagHousingPost(
      id: doc.id,
      name: data['name'] ?? '',
      housingTag: data['housingTag'] as DocumentReference?,
    );
  }
  
  factory TagHousingPost.fromMap(Map<String, dynamic> data) {
    return TagHousingPost(
      id: data['id'] ?? "",
      name: data['name'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'housingTag': housingTag,
    };
  }


}
