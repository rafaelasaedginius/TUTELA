import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/emergency_contact_model.dart';

class EmergencyContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _contactsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('contacts');
  }

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

  Future<void> addContact({
    required String uid,
    required String displayName,
    required String phoneNumber,
    required String relationship,
    required int priority,
    required bool notifyOnSos,
  }) async {
    final now = Timestamp.now();
    final contact = EmergencyContact(
      id: '',
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

  Future<void> updateContact({
    required String uid,
    required EmergencyContact contact,
  }) async {
    await _contactsRef(uid).doc(contact.id).update(contact.toUpdateMap());
  }

  Future<void> deleteContact({
    required String uid,
    required String contactId,
  }) async {
    await _contactsRef(uid).doc(contactId).delete();
  }
}
