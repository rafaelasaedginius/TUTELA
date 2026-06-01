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

  Stream<List<Incident>> streamIncidents() {
    return _incidents
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Incident.fromMap(doc.data(), doc.id))
        .toList());
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
}