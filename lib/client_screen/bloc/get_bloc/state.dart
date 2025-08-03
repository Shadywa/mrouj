import 'package:attendance_app/client_screen/model/model.dart';
import 'package:equatable/equatable.dart';

abstract class ClientState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {}

class ClientLoaded extends ClientState {
  final List<ClientModel> clients;
  ClientLoaded(this.clients);

  @override
  List<Object?> get props => [clients];
}

class ClientError extends ClientState {
  final String message;
  ClientError(this.message);

  @override
  List<Object?> get props => [message];
}
