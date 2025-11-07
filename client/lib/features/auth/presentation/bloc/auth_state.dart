import 'package:equatable/equatable.dart';
import 'package:trekka/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class RememberMeLoaded extends AuthState {
  final String email;
  final String password;

  const RememberMeLoaded({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}