import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String body;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String incidentId;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Comment({
    required this.id,
    required this.body,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.incidentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map, String id) {
    return Comment(
      id: id,
      body: map['body'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorAvatarUrl: map['authorAvatarUrl'],
      incidentId: map['incidentId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'body': body,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'incidentId': incidentId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}