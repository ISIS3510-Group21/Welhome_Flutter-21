import 'package:cloud_firestore/cloud_firestore.dart';
import 'roomie_tag.dart';

class StudentUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String photoPath;
  final String gender;
  final String password;
  final String nationality;
  final String language;
  final String birthDate;
  final String university;
  final List<RoomieTag> roomieTags;
  final List<DocumentReference> savedBookings;
  final List<DocumentReference> savedHousing;

  StudentUser({
    this.id = '',
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
    this.photoPath = '',
    this.gender = '',
    this.password = '',
    this.nationality = '',
    this.language = '',
    this.birthDate = '',
    this.university = '',
    this.roomieTags = const [],
    this.savedBookings = const [],
    this.savedHousing = const [],
  });

  factory StudentUser.fromMap(Map<String, dynamic> data, {String? documentId}) {
    return StudentUser(
      id: documentId ?? data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      photoPath: data['photoPath'] ?? '',
      gender: data['gender'] ?? '',
      password: data['password'] ?? '',
      nationality: data['nationality'] ?? '',
      language: data['language'] ?? '',
      birthDate: data['birthDate'] ?? '',
      university: data['university'] ?? '',
      roomieTags: (data['roomieTags'] as List<dynamic>?)
              ?.map((e) => RoomieTag.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      savedBookings: (data['savedBookings'] as List<dynamic>?)
              ?.map((e) => e as DocumentReference)
              .toList() ??
          [],
      savedHousing: (data['savedHousing'] as List<dynamic>?)
              ?.map((e) => e as DocumentReference)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoPath': photoPath,
      'gender': gender,
      'password': password,
      'nationality': nationality,
      'language': language,
      'birthDate': birthDate,
      'university': university,
      'roomieTags': roomieTags.map((e) => e.toMap()).toList(),
      'savedBookings': savedBookings,
      'savedHousing': savedHousing,
    };
  }
}
