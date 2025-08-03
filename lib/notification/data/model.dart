class NotificationModel {
  final int id;
  final String type;
  final String content;
  final String status;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.content,
    required this.status,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
