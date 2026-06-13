import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutela/models/attachment_model.dart';
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
  final List<Attachment> attachments;
  final Timestamp occurredAt;
  final int verifiedCount;
  final List<String> verifiedBy;
  final IncidentStatus status;
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
    this.attachments = const [],
    required this.occurredAt,
    this.verifiedCount = 0,
    this.verifiedBy = const [],
    this.status = IncidentStatus.active,
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
      attachments: (map['attachments'] as List<dynamic>?)
          ?.map((e) => Attachment.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
      occurredAt: map['occurredAt'] ?? Timestamp.now(),
      verifiedCount: map['verifiedCount'] ?? 0,
      verifiedBy: (map['verifiedBy'] as List<dynamic>?)?.cast<String>() ?? [],
      status: IncidentStatus.values.byName(map['status'] ?? 'active'),
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
      'attachments': attachments.map((e) => e.toMap()).toList(),
      'occurredAt': occurredAt,
      'verifiedCount': verifiedCount,
      'verifiedBy': verifiedBy,
      'status': status.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}