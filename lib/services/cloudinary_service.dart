import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart' as cp;
import 'package:tutela/models/cloudinaryImage_model.dart';

class CloudinaryService {
  CloudinaryService()
      : _cloudinary = cp.CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  static const String _cloudName = 'YOUR_CLOUD_NAME';
  static const String _uploadPreset = 'YOUR_UNSIGNED_PRESET';

  final cp.CloudinaryPublic _cloudinary;

  Future<CloudinaryImage> uploadImage(
      File file, {
        String folder = 'avatars',
      }) async {
    final response = await _cloudinary.uploadFile(
      cp.CloudinaryFile.fromFile(
        file.path,
        folder: folder,
        resourceType: cp.CloudinaryResourceType.Image,
      ),
    );

    return CloudinaryImage(
      publicId: response.publicId,
      secureUrl: response.secureUrl,
      format: response.data['format'] ?? '',
      width: response.data['width'] ?? 0,
      height: response.data['height'] ?? 0,
      bytes: response.data['bytes'] ?? 0,
      uploadedAt: Timestamp.now(),
    );
  }
}