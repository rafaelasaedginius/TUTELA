import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart' as cp;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tutela/models/attachment_model.dart';

class CloudinaryService {
  CloudinaryService()
      : _cloudinary = cp.CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '',
    dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '',
    cache: false,
  );

  final cp.CloudinaryPublic _cloudinary;

  Future<Attachment> uploadFile(
      File file, {
        String folder = 'attachments',
        cp.CloudinaryResourceType resourceType = cp.CloudinaryResourceType.Auto,
      }) async {
    final response = await _cloudinary.uploadFile(
      cp.CloudinaryFile.fromFile(
        file.path,
        folder: folder,
        resourceType: resourceType,
      ),
    );

    return Attachment(
      publicId: response.publicId,
      secureUrl: response.secureUrl,
      format: response.data['format'] ?? '',
      resourceType:
      response.data['resource_type'] ?? _resourceTypeName(resourceType),
      originalFilename: response.data['original_filename'] ??
          file.uri.pathSegments.last,
      width: response.data['width'] ?? 0,
      height: response.data['height'] ?? 0,
      bytes: response.data['bytes'] ?? 0,
      uploadedAt: Timestamp.now(),
    );
  }

  Future<Attachment> uploadImage(
      File file, {
        String folder = 'avatars',
      }) {
    return uploadFile(
      file,
      folder: folder,
      resourceType: cp.CloudinaryResourceType.Image,
    );
  }

  String _resourceTypeName(cp.CloudinaryResourceType type) {
    switch (type) {
      case cp.CloudinaryResourceType.Image:
        return 'image';
      case cp.CloudinaryResourceType.Video:
        return 'video';
      case cp.CloudinaryResourceType.Raw:
        return 'raw';
      case cp.CloudinaryResourceType.Auto:
        return 'auto';
    }
  }
}