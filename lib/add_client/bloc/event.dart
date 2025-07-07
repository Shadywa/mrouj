import 'package:attendance_app/add_client/model/add_model.dart';
import 'package:equatable/equatable.dart';

abstract class AddClientEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitAddClient extends AddClientEvent {
  final ClientaddModel client;
  SubmitAddClient(this.client);

  @override
  List<Object?> get props => [client];
}