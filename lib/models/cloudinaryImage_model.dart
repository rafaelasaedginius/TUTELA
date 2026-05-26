import 'package:cloud_firestore/cloud_firestore.dart';

class CloudinaryImage {
  final String publicId;
  final String secureUrl;
  final String format;
  final int width;
  final int height;
  final int bytes;
  final Timestamp uploadedAt;

  CloudinaryImage({
    required this.publicId,
    required this.secureUrl,
    required this.format,
    required this.width,
    required this.height,
    required this.bytes,
    required this.uploadedAt,
  });
  factory CloudinaryImage.fromMap(Map<String, dynamic> map) {
    return CloudinaryImage(
      publicId: map['publicId'] ?? '',
      secureUrl: map['secureUrl'] ?? '',
      format: map['format'] ?? '',
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
      'width': width,
      'height': height,
      'bytes': bytes,
      'uploadedAt': uploadedAt,
    };
  }
}