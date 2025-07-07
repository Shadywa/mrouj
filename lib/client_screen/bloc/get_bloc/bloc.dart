import 'dart:developer';

import 'package:attendance_app/client_screen/bloc/get_bloc/event.dart';
import 'package:attendance_app/client_screen/bloc/get_bloc/state.dart';
import 'package:attendance_app/client_screen/model/model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final Dio dio;
  ClientBloc(this.dio) : super(ClientInitial()) {
    on<FetchClients>(_onFetchClients);
  }

  Future<void> _onFetchClients(
    FetchClients event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      final department = prefs.getString('department')?.toLowerCase();
      log('Fetching clients for user ID: $uid, department: $department');

      late Response response;
      if (department == 'sales') {
        response = await dio.get(
          'https://drivo.elmoroj.com/api/customers/by-sales/$uid',
        );
      } else {
        response = await dio.get(
          'https://drivo.elmoroj.com/api/customers/by-account/$uid',
        );
      }

      final List data = response.data as List;
      final clients = data.map((e) => ClientModel.fromJson(e)).toList();
      emit(ClientLoaded(clients));
    } catch (e) {
      log(e.toString());
      emit(ClientError('فشل تحميل العملاء'));
    }
  }
}
