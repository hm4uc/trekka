import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthLoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginSubmitted(this.email, this.password);
}

class AuthRegisterSubmitted extends AuthEvent {
  final String fullname;
  final String email;
  final String password;
  const AuthRegisterSubmitted(this.fullname, this.email, this.password);
}

class AuthCheckRequested extends AuthEvent {}