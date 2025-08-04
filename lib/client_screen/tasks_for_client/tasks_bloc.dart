import 'package:flutter_bloc/flutter_bloc.dart';
import 'models.dart';
import 'api_service.dart';

abstract class TasksState {}
class TasksInitial extends TasksState {}
class TasksLoading extends TasksState {}
class TasksLoaded extends TasksState {
  final List<TaskCustomerModel> tasks;
  TasksLoaded(this.tasks);
}
class TasksError extends TasksState {
  final String message;
  TasksError(this.message);
}

abstract class TasksEvent {}
class FetchTasksEvent extends TasksEvent {
  final String customerId;
  FetchTasksEvent(this.customerId);
}

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskApiService apiService;
  TasksBloc(this.apiService) : super(TasksInitial()) {
    on<FetchTasksEvent>((event, emit) async {
      emit(TasksLoading());
      try {
        final tasks = await apiService.fetchTasksForCustomer(event.customerId);
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TasksError(e.toString()));
      }
    });
  }
}