class CommentModel {
  final String userId;
  final String userName;
  final String comment;
  final List<String> images;
  final String date;

  CommentModel({
    required this.userId,
    required this.userName,
    required this.comment,
    required this.images,
    required this.date,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    userId: json['user_id'] ?? '',
    userName: json['user_name'] ?? '',
    comment: json['comment'] ?? '',
    images: List<String>.from(json['images'] ?? []),
    date: json['date'] ?? '',
  );
}

class SubTaskModel {
  final int id;
  final int taskId;
  final String description;
  final List<String> images;
  final List<String> statusOptions;
  final String status;
  final List<String> attachmentTechnicial;
  final List<CommentModel> comments;
  final String createdBy;
  final int repeatCount;
  final String createdAt;
  final String updatedAt;

  SubTaskModel({
    required this.id,
    required this.taskId,
    required this.description,
    required this.images,
    required this.statusOptions,
    required this.status,
    required this.attachmentTechnicial,
    required this.comments,
    required this.createdBy,
    required this.repeatCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubTaskModel.fromJson(Map<String, dynamic> json) => SubTaskModel(
    id: json['id'],
    taskId: json['task_id'],
    description: json['description'] ?? '',
    images: List<String>.from(json['images'] ?? []),
    statusOptions: List<String>.from(json['status_options'] ?? []),
    status: json['status'] ?? '',
    attachmentTechnicial: List<String>.from(json['attachment_technicial'] ?? []),
    comments: (json['comments'] as List?)?.map((e) => CommentModel.fromJson(e)).toList() ?? [],
    createdBy: json['created_by'] ?? '',
    repeatCount: json['repeat_count'] ?? 0,
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'] ?? '',
  );
}

class TaskCustomerModel {
  final int id;
  final String userId;
  final String taskName;
  final String description;
  final String startTime;
  final String endTime;
  final String status;
  final String? image;
  final String createdAt;
  final String updatedAt;
  final int customerId;
  final List<SubTaskModel> subtasks;

  TaskCustomerModel({
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
    required this.customerId,
    required this.subtasks,
  });

  factory TaskCustomerModel.fromJson(Map<String, dynamic> json) => TaskCustomerModel(
    id: json['id'],
    userId: json['user_id'] ?? '',
    taskName: json['task_name'] ?? '',
    description: json['description'] ?? '',
    startTime: json['start_time'] ?? '',
    endTime: json['end_time'] ?? '',
    status: json['status'] ?? '',
    image: json['image'],
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'] ?? '',
    customerId: json['customer_id'] ?? 0,
    subtasks: (json['subtasks'] as List?)?.map((e) => SubTaskModel.fromJson(e)).toList() ?? [],
  );
}