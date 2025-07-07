class TaskModel {
  final int id;
  final String userId;
  final String taskName;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.userId,
    required this.taskName,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        userId: json['user_id'],
        taskName: json['task_name'],
        description: json['description'],
        startTime: DateTime.parse(json['start_time']),
        endTime: DateTime.parse(json['end_time']),
        status: json['status'],
        image: json['image'] ?? '',
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
}