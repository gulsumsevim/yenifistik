
class Comment {
  final int fieldId;
  final int commentId;
  final String fieldName;
  final String advisorName;
  final String advisorComment;
  final DateTime createdDate;

  Comment({
    required this.fieldId,
    required this.commentId,
    required this.fieldName,
    required this.advisorName,
    required this.advisorComment,
    required this.createdDate,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      fieldId: json['fieldId'],
      commentId: json['commentId'],
      fieldName: json['fieldName'],
      advisorName: json['advisorName'],
      advisorComment: json['advisorComment'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}
