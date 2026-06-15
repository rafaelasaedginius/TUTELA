import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutela/models/incident_model.dart';

class IncidentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _firestore.collection('incidents');

  Future<String> createIncident(Incident incident) async {
    final docRef = await _incidents.add(incident.toMap());
    return docRef.id;
  }

  Future<Incident?> getIncident(String id) async {
    final doc = await _incidents.doc(id).get();
    if (!doc.exists) return null;
    return Incident.fromMap(doc.data()!, doc.id);
  }

  Future<List<Incident>> getActiveIncidentsFiltered(String? category) async {
    var query = _incidents.where('status', isEqualTo: 'active');
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Incident.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<Incident>> streamIncidents() {
    return _incidents
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Incident.fromMap(doc.data(), doc.id))
        .toList());
  }

  Stream<List<Incident>> streamActiveIncidents() {
    return _incidents
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((s) =>
        s.docs.map((d) => Incident.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<Incident>> streamMyIncidents(String reporterId) {
    return _incidents
        .where('reporterId', isEqualTo: reporterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Incident.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> updateIncident(String id, Map<String, dynamic> data) async {
    await _incidents.doc(id).update({
      ...data,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteIncident(String id) async {
    await _incidents.doc(id).delete();
  }

  /// Marks incident [id] as resolved.
  Future<void> resolveIncident(String id) async {
    await updateIncident(id, {'status': 'resolved'});
  }

  /// Toggles verification for [userId] on incident [id].
  /// Adds the user to verifiedBy and increments verifiedCount if not yet
  /// verified, otherwise removes them and decrements the count.
  Future<void> toggleVerify(String id, String userId) async {
    final docRef = _incidents.doc(id);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final data = snapshot.data() as Map<String, dynamic>;
      final verifiedBy =
          (data['verifiedBy'] as List<dynamic>?)?.cast<String>() ?? [];
      final verifiedCount = (data['verifiedCount'] as int?) ?? 0;

      if (verifiedBy.contains(userId)) {
        transaction.update(docRef, {
          'verifiedBy': FieldValue.arrayRemove([userId]),
          'verifiedCount':
          verifiedCount > 0 ? verifiedCount - 1 : 0,
          'updatedAt': Timestamp.now(),
        });
      } else {
        transaction.update(docRef, {
          'verifiedBy': FieldValue.arrayUnion([userId]),
          'verifiedCount': verifiedCount + 1,
          'updatedAt': Timestamp.now(),
        });
      }
    });
  }
}