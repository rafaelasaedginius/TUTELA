import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutela/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<bool> isUsernameTaken(String username) async {
    final doc = await _firestore
        .collection('usernames')
        .doc(username.toLowerCase())
        .get();
    return doc.exists;
  }

  Future<void> createUser(User user) async {
    final usernameRef =
    _firestore.collection('usernames').doc(user.username.toLowerCase());
    final userRef = _users.doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final usernameDoc = await transaction.get(usernameRef);
      if (usernameDoc.exists) {
        throw Exception('Username already taken');
      }
      transaction.set(usernameRef, {'uid': user.uid});
      transaction.set(userRef, user.toMap());
    });
  }

  Future<User?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return User.fromMap(doc.data()!, doc.id);
  }

  Future<User?> getUserByEmail(String email) async {
    final query = await _users
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return User.fromMap(doc.data(), doc.id);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update({
      ...data,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteUserCascade(String uid) async {
    final userDoc = await _users.doc(uid).get();
    final username = userDoc.exists
        ? (userDoc.data()?['username'] as String?)
        : null;

    final contactsSnap =
        await _users.doc(uid).collection('contacts').get();
    for (final doc in contactsSnap.docs) {
      await doc.reference.delete();
    }

    final routesSnap = await _firestore
        .collection('safe_routes')
        .where('creatorId', isEqualTo: uid)
        .get();
    for (final doc in routesSnap.docs) {
      await doc.reference.delete();
    }

    final incidentsSnap = await _firestore
        .collection('incidents')
        .where('reporterId', isEqualTo: uid)
        .get();
    for (final doc in incidentsSnap.docs) {
      await doc.reference.delete();
    }

    await _users.doc(uid).delete();

    if (username != null && username.isNotEmpty) {
      await _firestore
          .collection('usernames')
          .doc(username.toLowerCase())
          .delete();
    }
  }
}