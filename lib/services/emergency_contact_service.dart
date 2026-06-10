import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/emergency_contact_model.dart';

/// Menangani seluruh operasi CRUD emergency contact di Cloud Firestore.
///
/// UI tidak perlu mengetahui sintaks query Firebase; UI cukup memanggil
/// method di service ini.
class EmergencyContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Semua kontak disimpan sebagai subcollection milik pengguna:
  /// users/{uid}/contacts/{contactId}
  CollectionReference<Map<String, dynamic>> _contactsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('contacts');
  }

  /// READ satu kali. Cocok jika UI tidak membutuhkan pembaruan real-time.
  Future<List<EmergencyContact>> getContacts(String uid) async {
    final snapshot = await _contactsRef(uid).orderBy('priority').get();
    final contacts = snapshot.docs
        .map((doc) => EmergencyContact.fromMap(doc.data(), doc.id))
        .toList();
    contacts.sort((a, b) {
      // Jika priority sama, kontak yang dibuat lebih dahulu tampil dahulu.
      final priorityCompare = a.priority.compareTo(b.priority);
      if (priorityCompare != 0) return priorityCompare;
      return a.createdAt.compareTo(b.createdAt);
    });
    return contacts;
  }

  /// READ real-time. Setiap perubahan Firestore mengirim daftar baru ke
  /// StreamBuilder di SafetyCircleScreen.
  Stream<List<EmergencyContact>> watchContacts(String uid) {
    return _contactsRef(uid).orderBy('priority').snapshots().map((snapshot) {
      final contacts = snapshot.docs
          .map((doc) => EmergencyContact.fromMap(doc.data(), doc.id))
          .toList();
      contacts.sort((a, b) {
        final priorityCompare = a.priority.compareTo(b.priority);
        if (priorityCompare != 0) return priorityCompare;
        return a.createdAt.compareTo(b.createdAt);
      });
      return contacts;
    });
  }

  /// Mengecek apakah priority sudah dimiliki kontak lain.
  ///
  /// [excludedContactId] digunakan saat UPDATE agar kontak yang sedang diedit
  /// tidak dianggap bentrok dengan priority miliknya sendiri.
  Future<bool> isPriorityTaken({
    required String uid,
    required int priority,
    String? excludedContactId,
  }) async {
    final snapshot = await _contactsRef(
      uid,
    ).where('priority', isEqualTo: priority).get();

    return snapshot.docs.any((doc) => doc.id != excludedContactId);
  }

  /// CREATE dokumen baru. Firestore membuat contactId secara otomatis karena
  /// method yang digunakan adalah add().
  Future<void> addContact({
    required String uid,
    required String displayName,
    required String phoneNumber,
    required String relationship,
    required int priority,
    required bool notifyOnSos,
  }) async {
    // createdAt dan updatedAt sama saat kontak pertama kali dibuat.
    final now = Timestamp.now();
    final contact = EmergencyContact(
      id: '',
      userId: uid,
      displayName: displayName,
      phoneNumber: phoneNumber,
      relationship: relationship,
      priority: priority,
      notifyOnSos: notifyOnSos,
      createdAt: now,
      updatedAt: now,
    );

    await _contactsRef(uid).add(contact.toMap());
  }

  /// UPDATE dokumen yang sudah ada menggunakan contact.id.
  Future<void> updateContact({
    required String uid,
    required EmergencyContact contact,
  }) async {
    await _contactsRef(uid).doc(contact.id).update(contact.toUpdateMap());
  }

  /// DELETE dokumen kontak secara permanen dari subcollection pengguna.
  Future<void> deleteContact({
    required String uid,
    required String contactId,
  }) async {
    await _contactsRef(uid).doc(contactId).delete();
  }
}
