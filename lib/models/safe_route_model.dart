import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutela/models/geo_location_model.dart';

class SafeRoute {
  final String id;
  final String creatorId;
  final String name;
  final GeoLocation origin;
  final GeoLocation destination;
  final List<String> safetyTags;
  final bool isShared;
  final bool isFlagged;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const SafeRoute({
    required this.id,
    required this.creatorId,
    required this.name,
    required this.origin,
    required this.destination,
    this.safetyTags = const [],
    this.isShared = false,
    this.isFlagged = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SafeRoute.fromMap(Map<String, dynamic> map, String id) {
    return SafeRoute(
      id: id,
      creatorId: map['creatorId'] ?? '',
      name: map['name'] ?? '',
      origin: GeoLocation.fromMap(map['origin'] as Map<String, dynamic>),
      destination: GeoLocation.fromMap(
          map['destination'] as Map<String, dynamic>),
      safetyTags: List<String>.from(map['safetyTags'] ?? []),
      isShared: map['isShared'] ?? false,
      isFlagged: map['isFlagged'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'name': name,
      'origin': origin.toMap(),
      'destination': destination.toMap(),
      'safetyTags': safetyTags,
      'isShared': isShared,
      'isFlagged': isFlagged,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
