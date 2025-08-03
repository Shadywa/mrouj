import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import '../task_comment_bloc/task_comment_event.dart';
import '../task_comment_bloc/task_comment_state.dart';
import '../model/task_comment.dart';

class TaskCommentBloc extends Bloc<TaskCommentEvent, TaskCommentState> {
  final Dio dio;
  TaskCommentBloc(this.dio) : super(TaskCommentInitial()) {
    on<FetchTaskCommentsEvent>(_onFetchComments);
    on<AddTaskCommentEvent>(_onAddComment);
  }

  Future<void> _onFetchComments(FetchTaskCommentsEvent event, Emitter<TaskCommentState> emit) async {
    emit(TaskCommentLoading());
    try {
      final response = await dio.get('https://drivo.elmoroj.com/api/tasks/${event.taskId}/comments');
      final List data = response.data['task_comments'] ?? [];
      final comments = data.map((e) => TaskComment.fromJson(e)).toList();
      emit(TaskCommentLoaded(comments));
    } catch (e) {
      emit(TaskCommentError('فشل تحميل التعليقات'));
    }
  }

  Future<void> _onAddComment(AddTaskCommentEvent event, Emitter<TaskCommentState> emit) async {
    emit(TaskCommentLoading());
    try {
      FormData formData = FormData.fromMap({
        'comment': event.comment,
        if (event.images.isNotEmpty)
          'images': [for (var img in event.images) await MultipartFile.fromFile(img.path)],
      });
      await dio.post('https://drivo.elmoroj.com/api/tasks/${event.taskId}/add-comment', data: formData);
      emit(TaskCommentSuccess('تم إضافة التعليق بنجاح'));
      add(FetchTaskCommentsEvent(event.taskId));
    } catch (e) {
      emit(TaskCommentError('فشل إضافة التعليق'));
    }
  }
}
