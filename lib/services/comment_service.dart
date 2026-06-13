import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'comments';

  CollectionReference<Map<String, dynamic>> get _commentsRef =>
      _firestore.collection(_collection);

  Future<Comment> createComment({
    required String body,
    required String authorId,
    required String authorName,
    String? authorAvatarUrl,
    required String incidentId,
  }) async {
    final now = Timestamp.now();

    final docRef = await _commentsRef.add({
      'body': body,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'incidentId': incidentId,
      'createdAt': now,
      'updatedAt': now,
    });

    return Comment(
      id: docRef.id,
      body: body,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      incidentId: incidentId,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<Comment?> getCommentById(String commentId) async {
    final doc = await _commentsRef.doc(commentId).get();

    if (!doc.exists || doc.data() == null) return null;

    return Comment.fromMap(doc.data()!, doc.id);
  }

  Future<List<Comment>> getCommentsByIncident(String incidentId) async {
    final snapshot = await _commentsRef
        .where('incidentId', isEqualTo: incidentId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => Comment.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<Comment>> watchCommentsByIncident(String incidentId) {
    return _commentsRef
        .where('incidentId', isEqualTo: incidentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Comment.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> updateComment({
    required String commentId,
    required String newBody,
  }) async {
    await _commentsRef.doc(commentId).update({
      'body': newBody,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteComment(String commentId) async {
    await _commentsRef.doc(commentId).delete();
  }

  Future<void> deleteCommentsByIncident(String incidentId) async {
    final snapshot = await _commentsRef
        .where('incidentId', isEqualTo: incidentId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}