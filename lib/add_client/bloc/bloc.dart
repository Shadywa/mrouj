import 'dart:developer';

import 'package:attendance_app/add_client/bloc/event.dart';
import 'package:attendance_app/add_client/bloc/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

class AddClientBloc extends Bloc<AddClientEvent, AddClientState> {
  final Dio dio;
  AddClientBloc(this.dio) : super(AddClientInitial()) {
    on<SubmitAddClient>(_onSubmitAddClient);
  }

  Future<void> _onSubmitAddClient(
    SubmitAddClient event,
    Emitter<AddClientState> emit,
  ) async {
    emit(AddClientLoading());
    try {
      log('Submitting client: ${event.client.toJson()}');
      final Response = await dio.post(
        'https://drivo.elmoroj.com/api/customers',
        data: event.client.toJson(),
      );
      log(Response.data.toString());
      emit(AddClientSuccess());
    } catch (e) {
      log(e.toString());
      emit(AddClientError('فشل إضافة العميل'));
    }
  }
}
