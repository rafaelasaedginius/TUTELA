import 'package:cloud_firestore/cloud_firestore.dart';

class Attachment {
  final String publicId;
  final String secureUrl;
  final String format;
  final String resourceType;
  final String originalFilename;
  final int width;
  final int height;
  final int bytes;
  final Timestamp uploadedAt;

  Attachment({
    required this.publicId,
    required this.secureUrl,
    required this.format,
    this.resourceType = 'image',
    this.originalFilename = '',
    this.width = 0,
    this.height = 0,
    this.bytes = 0,
    required this.uploadedAt,
  });

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      publicId: map['publicId'] ?? '',
      secureUrl: map['secureUrl'] ?? '',
      format: map['format'] ?? '',
      resourceType: map['resourceType'] ?? 'image',
      originalFilename: map['originalFilename'] ?? '',
      width: map['width'] ?? 0,
      height: map['height'] ?? 0,
      bytes: map['bytes'] ?? 0,
      uploadedAt: map['uploadedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'publicId': publicId,
      'secureUrl': secureUrl,
      'format': format,
      'resourceType': resourceType,
      'originalFilename': originalFilename,
      'width': width,
      'height': height,
      'bytes': bytes,
      'uploadedAt': uploadedAt,
    };
  }

  bool get isImage => resourceType == 'image';
  bool get isVideo => resourceType == 'video';
  bool get isRaw => resourceType == 'raw';

  String get displayName =>
      originalFilename.isEmpty ? publicId.split('/').last : originalFilename;
}