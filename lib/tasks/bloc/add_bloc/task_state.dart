import 'package:equatable/equatable.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}
class TaskLoading extends TaskState {}
class TaskSuccess extends TaskState {
  final String message;
  TaskSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
  @override
  List<Object?> get props => [message];
}
class TasksLoaded extends TaskState {
  final List<dynamic> tasks;
  TasksLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}
