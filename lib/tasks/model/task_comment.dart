class TaskComment {
  final String userId;
  final String userName;
  final String comment;
  final List<String> images;
  final String date;

  TaskComment({
    required this.userId,
    required this.userName,
    required this.comment,
    required this.images,
    required this.date,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) => TaskComment(
        userId: json['user_id'],
        userName: json['user_name'],
        comment: json['comment'],
        images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
        date: json['date'],
      );
}
