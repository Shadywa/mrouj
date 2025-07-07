import 'package:equatable/equatable.dart';

abstract class ClientEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchClients extends ClientEvent {}