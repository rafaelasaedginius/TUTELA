import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutela/models/cloudinaryImage_model.dart';

class User {
  final String uid;
  final String username;
  final String email;
  final String name;
  final String phoneNumber;
  final String? homeCity;
  final CloudinaryImage? avatar;
  final List<String> trustedGroupIds;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  User({
    required this.uid,
    required this.username,
    required this.email,
    required this.name,
    required this.phoneNumber,
    this.homeCity,
    this.avatar,
    this.trustedGroupIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      uid: id,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      homeCity: map['homeCity'],
      avatar: map['avatar'] == null
          ? null
          : CloudinaryImage.fromMap(map['avatar'] as Map<String, dynamic>),
      trustedGroupIds:
      (map['trustedGroupIds'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'homeCity': homeCity,
      'avatar': avatar?.toMap(),
      'trustedGroupIds': trustedGroupIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
