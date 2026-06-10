import 'package:cloud_firestore/cloud_firestore.dart';

/// Bentuk data satu emergency contact di dalam aplikasi.
///
/// Model tidak berkomunikasi langsung dengan Firebase. Tugasnya hanya
/// menyimpan data dan mengubah data Dart <-> Map Firestore.
class EmergencyContact {
  const EmergencyContact({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.phoneNumber,
    required this.relationship,
    required this.priority,
    required this.notifyOnSos,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String displayName;
  final String phoneNumber;
  final String relationship;
  final int priority;
  final bool notifyOnSos;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  /// Mengubah dokumen Firestore menjadi object EmergencyContact.
  ///
  /// Nilai default menjaga UI tetap dapat ditampilkan jika field lama belum
  /// lengkap, tetapi Firestore rules tetap perlu memvalidasi data sebenarnya.
  factory EmergencyContact.fromMap(Map<String, dynamic> map, String id) {
    return EmergencyContact(
      id: id,
      userId: map['userId'] ?? '',
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      relationship: map['relationship'] ?? '',
      priority: map['priority'] ?? 1,
      notifyOnSos: map['notifyOnSos'] ?? true,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  /// Dipakai saat CREATE karena seluruh field perlu disimpan.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'priority': priority,
      'notifyOnSos': notifyOnSos,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Dipakai saat UPDATE.
  ///
  /// id, userId, dan createdAt sengaja tidak ditimpa. updatedAt memakai waktu
  /// terbaru agar perubahan terakhir dapat dilacak.
  Map<String, dynamic> toUpdateMap() {
    return {
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'priority': priority,
      'notifyOnSos': notifyOnSos,
      'updatedAt': Timestamp.now(),
    };
  }
}
