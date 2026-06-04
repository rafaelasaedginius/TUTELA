import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutela/models/safe_route_model.dart';

class SafeRouteService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('safe_routes');

  Future<String> createRoute(SafeRoute route) async {
    final ref = await _col.add(route.toMap());
    return ref.id;
  }

  Future<SafeRoute?> getRoute(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return SafeRoute.fromMap(doc.data()!, doc.id);
  }

  Stream<List<SafeRoute>> streamMyRoutes(String creatorId) {
    return _col
        .where('creatorId', isEqualTo: creatorId)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => SafeRoute.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<SafeRoute>> streamSharedRoutes() {
    return _col
        .where('isShared', isEqualTo: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => SafeRoute.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateRoute(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update({...data, 'updatedAt': Timestamp.now()});
  }

  Future<void> deleteRoute(String id) async {
    await _col.doc(id).delete();
  }
}
