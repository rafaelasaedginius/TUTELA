import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String body;
  final String authorId;
  final String incidentId;
  final Timestamp updatedAt;
  final Timestamp createdAt;

  const Comment({
    required this.id,
    required this.body,
    required this.authorId,
    required this.incidentId,
    required this.updatedAt,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map, String id) {
    return Comment (
      id: id,
      body: map['body'] ?? '',
      authorId: map['authorId'] ?? '',
      incidentId: map['incidentId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'body': body,
      'authorId': authorId,
      'incidentId': incidentId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}