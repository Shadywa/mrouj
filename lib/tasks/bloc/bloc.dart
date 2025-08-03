import 'dart:developer';

import 'package:attendance_app/tasks/bloc/event.dart';
import 'package:attendance_app/tasks/bloc/state.dart';
import 'package:attendance_app/tasks/screen/model/task.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final Dio dio;
  TaskBloc(this.dio) : super(TaskInitial()) {
    on<FetchTasks>(_onFetchTasks);
  }

  Future<void> _onFetchTasks(FetchTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null) {
        emit(TaskError('لم يتم العثور على المستخدم'));
        return;
      }
      final response = await dio.get('https://drivo.elmoroj.com/api/user-tasks/$uid');
      final List data = response.data as List;
      final tasks = data.map((e) => TaskModel.fromJson(e)).toList();
      log('TASKS: ${tasks.length}');
      log('TASKS: ${tasks.map((e) => e.id).toList()}');
      emit(TaskLoaded(tasks));
    } catch (e) {
      log('Error fetching tasks: $e');
      emit(TaskError('فشل تحميل المهام'));
    }
  }
}