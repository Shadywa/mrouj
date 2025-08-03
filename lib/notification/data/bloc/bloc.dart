import 'package:attendance_app/notification/data/model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NotificationEvent {}

class FetchNotificationsEvent extends NotificationEvent {}

class MarkNotificationsAsReadEvent extends NotificationEvent {
  MarkNotificationsAsReadEvent();
}

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  NotificationLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final Dio dio;

  NotificationBloc(this.dio) : super(NotificationInitial()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<MarkNotificationsAsReadEvent>(_onMarkAsRead); // 👈 الحدث الجديد
  }

  Future<void> _onFetchNotifications(
    FetchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final userId = await SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('uid') ?? '',
      );
      final response = await dio.get(
        'https://drivo.elmoroj.com/api/notifications/user/$userId',
      );
      final List data = response.data;
      final notifications =
          data
              .map((json) => NotificationModel.fromJson(json))
              .toList()
              .cast<NotificationModel>();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError('فشل تحميل الإشعارات'));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationsAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final userId = await SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('uid') ?? '',
      );
      await dio.put(
        'https://drivo.elmoroj.com/api/notifications/user/$userId/read',
        options: Options(
          headers: {
            'Accept': 'application/json',
            // 'Authorization': 'Bearer token' ← لو محتاج توكن
          },
        ),
      );
      print('✅ تم تعليم الإشعارات كمقروءة');
    } catch (e) {
      print('❌ فشل تعليم الإشعارات كمقروءة: $e');
    }
  }
}
