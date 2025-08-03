import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddTaskEvent extends TaskEvent {
  final String userId;
  final String taskName;
  final String description;
  final String startTime;
  final String endTime;
  final String status;
  final File? image;

  AddTaskEvent({
    required this.userId,
    required this.taskName,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.image,
  });

  @override
  List<Object?> get props => [userId, taskName, description, startTime, endTime, status, image];
}

class FetchTasksEvent extends TaskEvent {
  final String userId;
  FetchTasksEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}
