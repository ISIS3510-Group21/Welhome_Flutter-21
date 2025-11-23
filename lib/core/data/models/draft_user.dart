import 'package:equatable/equatable.dart';

class DraftUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String password;
  final DateTime birthDate;
  final String? gender;
  final String? nationality;
  final String? language;
  final String phoneNumber;
  final String phonePrefix;
  final String userType; // "student" or "host"
  final String? localImagePath; // Local path to profile image

  // Sync metadata
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final bool isSyncing;
  final bool isSynced;
  final String? syncError;
  final String? remoteUserId; // Firebase UID after sync

  const DraftUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.birthDate,
    this.gender,
    this.nationality,
    this.language,
    required this.phoneNumber,
    required this.phonePrefix,
    required this.userType,
    this.localImagePath,
    required this.createdAt,
    required this.lastModifiedAt,
    this.isSyncing = false,
    this.isSynced = false,
    this.syncError,
    this.remoteUserId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        password,
        birthDate,
        gender,
        nationality,
        language,
        phoneNumber,
        phonePrefix,
        userType,
        localImagePath,
        createdAt,
        lastModifiedAt,
        isSyncing,
        isSynced,
        syncError,
        remoteUserId,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'nationality': nationality,
      'language': language,
      'phoneNumber': phoneNumber,
      'phonePrefix': phonePrefix,
      'userType': userType,
      'localImagePath': localImagePath,
      'createdAt': createdAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
      'isSyncing': isSyncing,
      'isSynced': isSynced,
      'syncError': syncError,
      'remoteUserId': remoteUserId,
    };
  }

  factory DraftUser.fromMap(Map<String, dynamic> map) {
    return DraftUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      birthDate: DateTime.parse(map['birthDate'] as String),
      gender: map['gender'] as String?,
      nationality: map['nationality'] as String?,
      language: map['language'] as String?,
      phoneNumber: map['phoneNumber'] as String,
      phonePrefix: map['phonePrefix'] as String,
      userType: map['userType'] as String,
      localImagePath: map['localImagePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastModifiedAt: DateTime.parse(map['lastModifiedAt'] as String),
      isSyncing: map['isSyncing'] as bool? ?? false,
      isSynced: map['isSynced'] as bool? ?? false,
      syncError: map['syncError'] as String?,
      remoteUserId: map['remoteUserId'] as String?,
    );
  }

  DraftUser copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    DateTime? birthDate,
    String? gender,
    String? nationality,
    String? language,
    String? phoneNumber,
    String? phonePrefix,
    String? userType,
    String? localImagePath,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    bool? isSyncing,
    bool? isSynced,
    String? syncError,
    String? remoteUserId,
  }) {
    return DraftUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      language: language ?? this.language,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phonePrefix: phonePrefix ?? this.phonePrefix,
      userType: userType ?? this.userType,
      localImagePath: localImagePath ?? this.localImagePath,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      isSyncing: isSyncing ?? this.isSyncing,
      isSynced: isSynced ?? this.isSynced,
      syncError: syncError ?? this.syncError,
      remoteUserId: remoteUserId ?? this.remoteUserId,
    );
  }
}
