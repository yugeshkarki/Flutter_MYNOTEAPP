import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String uid;
  final String title;
  final String content;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.uid,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json, String id) => Note(
        id: id,
        uid: json['uid'] ?? '',
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'title': title,
        'content': content,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
