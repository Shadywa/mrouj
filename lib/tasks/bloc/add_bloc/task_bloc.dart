import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final Dio dio;
  TaskBloc(this.dio) : super(TaskInitial()) {
    on<AddTaskEvent>(_onAddTask);
    on<FetchTasksEvent>(_onFetchTasks);
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
        final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      final response = await dio.post(
        'https://drivo.elmoroj.com/api/tasks',
        data: {
          'user_id': uid,
          'task_name': event.taskName,
          'description': event.description,
          'start_time': event.startTime,
          'end_time': event.endTime,
          'status': event.status,
        },
      );
      emit(TaskSuccess('تم إضافة المهمة بنجاح'));
    } catch (e) {
      emit(TaskError('فشل إضافة المهمة'));
    }
  }

  Future<void> _onFetchTasks(FetchTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final response = await dio.get(
        'https://drivo.elmoroj.com/api/tasks',
        queryParameters: {'user_id': event.userId},
      );
      emit(TasksLoaded(response.data['tasks'] ?? []));
    } catch (e) {
      emit(TaskError('فشل تحميل المهام'));
    }
  }
}
