import 'package:equatable/equatable.dart';
import '../model/task_comment.dart';

abstract class TaskCommentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskCommentInitial extends TaskCommentState {}
class TaskCommentLoading extends TaskCommentState {}
class TaskCommentLoaded extends TaskCommentState {
  final List<TaskComment> comments;
  TaskCommentLoaded(this.comments);
  @override
  List<Object?> get props => [comments];
}
class TaskCommentError extends TaskCommentState {
  final String message;
  TaskCommentError(this.message);
  @override
  List<Object?> get props => [message];
}
class TaskCommentSuccess extends TaskCommentState {
  final String message;
  TaskCommentSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
