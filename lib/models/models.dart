import 'package:cloud_firestore/cloud_firestore.dart';

class Experience {
  final String? id;
  final String role;
  final String company;
  final String startDate;
  final String endDate;
  final String description;

  Experience({
    this.id,
    required this.role,
    required this.company,
    required this.startDate,
    required this.endDate,
    this.description = '',
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'company': company,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }

  // Create from Firestore document
  factory Experience.fromMap(Map<String, dynamic> map, String id) {
    return Experience(
      id: id,
      role: map['role'] ?? '',
      company: map['company'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Experience copyWith({
    String? id,
    String? role,
    String? company,
    String? startDate,
    String? endDate,
    String? description,
  }) {
    return Experience(
      id: id ?? this.id,
      role: role ?? this.role,
      company: company ?? this.company,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
    );
  }
}

// Education Model
class Education {
  final String? id;
  final String school;
  final String degree;
  final String fieldOfStudy;
  final String startYear;
  final String endYear;

  Education({
    this.id,
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.startYear,
    required this.endYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'school': school,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'startYear': startYear,
      'endYear': endYear,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map, String id) {
    return Education(
      id: id,
      school: map['school'] ?? '',
      degree: map['degree'] ?? '',
      fieldOfStudy: map['fieldOfStudy'] ?? '',
      startYear: map['startYear'] ?? '',
      endYear: map['endYear'] ?? '',
    );
  }

  Education copyWith({
    String? id,
    String? school,
    String? degree,
    String? fieldOfStudy,
    String? startYear,
    String? endYear,
  }) {
    return Education(
      id: id ?? this.id,
      school: school ?? this.school,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
    );
  }
}

// User Profile Model
class UserProfile {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String bio;
  final List<String> skills;
  final List<Experience> experiences;
  final List<Education> educations;
  final List<String> interests;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber = '',
    this.bio = '',
    this.skills = const [],
    this.experiences = const [],
    this.educations = const [],
    this.interests = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'skills': skills,
      'experiences': experiences.map((e) => e.toMap()).toList(),
      'educations': educations.map((e) => e.toMap()).toList(),
      'interests': interests,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      bio: map['bio'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      experiences:
          (map['experiences'] as List<dynamic>? ?? [])
              .asMap()
              .entries
              .map(
                (e) => Experience.fromMap(
                  e.value as Map<String, dynamic>,
                  e.key.toString(),
                ),
              )
              .toList(),
      educations:
          (map['educations'] as List<dynamic>? ?? [])
              .asMap()
              .entries
              .map(
                (e) => Education.fromMap(
                  e.value as Map<String, dynamic>,
                  e.key.toString(),
                ),
              )
              .toList(),
      interests: List<String>.from(map['interests'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Copy with method for creating modified versions
  UserProfile copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? bio,
    List<String>? skills,
    List<Experience>? experiences,
    List<Education>? educations,
    List<String>? interests,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      experiences: experiences ?? this.experiences,
      educations: educations ?? this.educations,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
