import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class ClientActionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddCommentEvent extends ClientActionEvent {
  final String clientId;
  final String comment;
  final List uid;
  AddCommentEvent(this.clientId, this.comment, this.uid);

  @override
  List<Object?> get props => [clientId, comment, uid];
}

class ChangeStatusEvent extends ClientActionEvent {
  final String clientId;
  final String newStatus;
  ChangeStatusEvent(this.clientId, this.newStatus);

  @override
  List<Object?> get props => [clientId, newStatus];
}

class AddWorkCommentEvent extends ClientActionEvent {
  final String clientId;
  final String department;

  final String comment;
  final List<String> uids;
  AddWorkCommentEvent({
    required this.clientId,
    required this.comment,
    required this.uids,
    required this.department,
  });

  @override
  List<Object?> get props => [clientId, comment, uids];
}

class UpdateClientEvent extends ClientActionEvent {
  final String id;
  final List<String> uids;
  final String name;
  final String email;
  final String phone;
  final DateTime? nextContactAt;
  final String status;

  UpdateClientEvent({
    required this.id,
    required this.name,
    required this.uids,
    required this.email,
    required this.phone,
    required this.nextContactAt,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, email, phone, nextContactAt, status];
}

class AddGeneralWorkCommentEvent extends ClientActionEvent {
  final String clientId;
  final String department;
  final String comment;
  final List<String> uids;
  AddGeneralWorkCommentEvent({
    required this.clientId,
    required this.comment,
    required this.uids,
    required this.department,
  });

  @override
  List<Object?> get props => [clientId, comment, uids, department];
}

// States
abstract class ClientActionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ClientActionInitial extends ClientActionState {}

class ClientActionLoading extends ClientActionState {}

class ClientActionSuccess extends ClientActionState {
  final String message;
  ClientActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ClientActionError extends ClientActionState {
  final String message;
  ClientActionError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ClientActionBloc extends Bloc<ClientActionEvent, ClientActionState> {
  final Dio dio;
  ClientActionBloc(this.dio) : super(ClientActionInitial()) {
    //   on<ChangeStatusEvent>(_onChangeStatus);
    on<AddWorkCommentEvent>(_onAddWorkComment);
    on<UpdateClientEvent>(_onUpdateClient); // أضف هذا السطر
    on<AddGeneralWorkCommentEvent>(_onAddGeneralWorkComment);
  }

  Future<void> _onAddWorkComment(
    AddWorkCommentEvent event,
    Emitter<ClientActionState> emit,
  ) async {
    emit(ClientActionLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');

      // تحديد الرابط المناسب حسب الـ department
      String url;
      if (event.department.toLowerCase() == 'finance') {
        url =
            'https://drivo.elmoroj.com/api/customers/${event.clientId}/account-comments/add';
      } else if (event.department.toLowerCase() == 'social') {
        url =
            'https://drivo.elmoroj.com/api/customers/${event.clientId}/add-socialmedia-comment';
      } else {
        // sales أو أي قسم آخر
        url =
            'https://drivo.elmoroj.com/api/customers/${event.clientId}/add-work-comment';
      }

      await dio.post(url, data: {'user_id': uid, 'comment': event.comment});
      log('Work comment added: ${event.uids} - ${event.comment}');
      emit(ClientActionSuccess('تم إضافة تعليق العمل بنجاح'));

      // إرسال إشعار لكل uids بعد نجاح إضافة التعليق (لا يؤثر على حالة الـ bloc)
      if (event.uids.isNotEmpty) {
        log('Sending notification to uids: ${event.uids}');
        try {
          final response = await dio.post(
            'https://us-central1-eljudymarket.cloudfunctions.net/sendNotificationToUsers',
            data: jsonEncode({
              'uids': event.uids,
              'title': '   تعليق عمل جديد',
              'body': event.comment,
            }),
            options: Options(headers: {'Content-Type': 'application/json'}),
          );
          log('Response from notification API: ${response.data}');
        } catch (e) {
          log('Notification send error: $e');
        }
      }
    } catch (e) {
      log('Error adding work comment: $e');
      emit(ClientActionError('فشل إضافة تعليق العمل'));
    }
  }

  // أضف دالة المعالجة:
  Future<void> _onUpdateClient(
    UpdateClientEvent event,
    Emitter<ClientActionState> emit,
  ) async {
    emit(ClientActionLoading());
    try {
      await dio.post(
        'https://drivo.elmoroj.com/api/customers/update/${event.id}',
        data: {
          'name': event.name,
          'email': event.email,
          'phone': event.phone,
          'next_contact_at': event.nextContactAt?.toIso8601String(),
          'status': event.status,
        },
      );
      log('Client updated: ${event.id} - ${event.name}');
      log('Client update data: ${event.nextContactAt?.toIso8601String()}');
      emit(ClientActionSuccess('تم تحديث بيانات العميل بنجاح'));

      if (event.uids.isNotEmpty) {
        log('Sending notification to uids: ${event.uids}');
        try {
          final response = await dio.post(
            'https://us-central1-eljudymarket.cloudfunctions.net/sendNotificationToUsers',
            data: jsonEncode({
              'uids': event.uids,
              'title': '  عميل ${event.name} تم تحديث بياناته',
              'body': 'تم تحديث بيانات العميل',
            }),
            options: Options(headers: {'Content-Type': 'application/json'}),
          );
          log('Response from notification API: ${response.data}');
        } catch (e) {
          log('Notification send error: $e');
        }
      }
    } catch (e) {
      log('Error updating client: $e');
      emit(ClientActionError('فشل تحديث بيانات العميل'));
    }
  }

  Future<void> _onAddGeneralWorkComment(
    AddGeneralWorkCommentEvent event,
    Emitter<ClientActionState> emit,
  ) async {
    emit(ClientActionLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      final url = 'https://drivo.elmoroj.com/api/customers/${event.clientId}/add-general-comment';
      await dio.post(url, data: {'user_id': uid, 'comment': event.comment});
      log('General comment added: ${event.uids} - ${event.comment}');
      emit(ClientActionSuccess('تم إضافة التعليق العام بنجاح'));
      if (event.uids.isNotEmpty) {
        log('Sending notification to uids: ${event.uids}');
        try {
          final response = await dio.post(
            'https://us-central1-eljudymarket.cloudfunctions.net/sendNotificationToUsers',
            data: jsonEncode({
              'uids': event.uids,
              'title': 'تعليق عام جديد',
              'body': event.comment,
            }),
            options: Options(headers: {'Content-Type': 'application/json'}),
          );
          log('Response from notification API: \\${response.data}');
        } catch (e) {
          log('Notification send error: $e');
        }
      }
    } catch (e) {
      log('Error adding general comment: $e');
      emit(ClientActionError('فشل إضافة التعليق العام'));
    }
  }
}
