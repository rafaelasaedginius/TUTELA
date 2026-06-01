import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutela/models/cloudinaryImage_model.dart';
import 'package:tutela/models/geo_location_model.dart';
import 'package:tutela/models/incident_enums.dart';

class Incident {
  final String id;
  final String reporterId;
  final String title;
  final String description;
  final IncidentCategory category;
  final Severity severity;
  final GeoLocation location;
  final String geohash;
  final List<CloudinaryImage> photos;
  final Timestamp occurredAt;
  final int verifiedCount;
  final IncidentStatus status;
  final bool isDeleted;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Incident({
    required this.id,
    required this.reporterId,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.location,
    required this.geohash,
    this.photos = const [],
    required this.occurredAt,
    this.verifiedCount = 0,
    this.status = IncidentStatus.active,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Incident.fromMap(Map<String, dynamic> map, String id) {
    return Incident(
      id: id,
      reporterId: map['reporterId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: IncidentCategory.values.byName(map['category'] ?? 'other'),
      severity: Severity.values.byName(map['severity'] ?? 'low'),
      location: map['location'] == null
          ? const GeoLocation(latitude: 0, longitude: 0)
          : GeoLocation.fromMap(map['location'] as Map<String, dynamic>),
      geohash: map['geohash'] ?? '',
      photos: (map['photos'] as List<dynamic>?)
          ?.map((e) => CloudinaryImage.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
      occurredAt: map['occurredAt'] ?? Timestamp.now(),
      verifiedCount: map['verifiedCount'] ?? 0,
      status: IncidentStatus.values.byName(map['status'] ?? 'active'),
      isDeleted: map['isDeleted'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'title': title,
      'description': description,
      'category': category.name,
      'severity': severity.name,
      'location': location.toMap(),
      'geohash': geohash,
      'photos': photos.map((e) => e.toMap()).toList(),
      'occurredAt': occurredAt,
      'verifiedCount': verifiedCount,
      'status': status.name,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}