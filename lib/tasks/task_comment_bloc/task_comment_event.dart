import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class TaskCommentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTaskCommentsEvent extends TaskCommentEvent {
  final int taskId;
  FetchTaskCommentsEvent(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class AddTaskCommentEvent extends TaskCommentEvent {
  final int taskId;
  final String comment;
  final List<File> images;
  AddTaskCommentEvent({required this.taskId, required this.comment, this.images = const []});
  @override
  List<Object?> get props => [taskId, comment, images];
}
