import 'package:cloud_firestore/cloud_firestore.dart';
import 'housing_preview.dart';

class StudentUserProfile {
  final String id;
  final DocumentReference? userId;
  final List<DocumentReference> usedTags;
  final List<HousingPreview> visitedHousingPosts;

  StudentUserProfile({
    this.id = '',
    this.userId,
    this.usedTags = const [],
    this.visitedHousingPosts = const [],
  });

  factory StudentUserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return StudentUserProfile(
      id: doc.id,
      userId: data['userId'] as DocumentReference?,
      usedTags: (data['usedTags'] as List<dynamic>?)
              ?.map((e) => e as DocumentReference)
              .toList() ??
          [],
      visitedHousingPosts: (data['visitedHousingPosts'] as List<dynamic>?)
              ?.map((e) => HousingPreview.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'usedTags': usedTags,
      'visitedHousingPosts': visitedHousingPosts.map((e) => e.toMap()).toList(),
    };
  }
}
