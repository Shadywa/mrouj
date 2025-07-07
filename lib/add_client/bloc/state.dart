import 'package:equatable/equatable.dart';

abstract class AddClientState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddClientInitial extends AddClientState {}

class AddClientLoading extends AddClientState {}

class AddClientSuccess extends AddClientState {}

class AddClientError extends AddClientState {
  final String message;
  AddClientError(this.message);

  @override
  List<Object?> get props => [message];
}