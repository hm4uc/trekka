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

class AuthLogoutRequested extends AuthEvent {}

class AuthLogoutAllDevicesRequested extends AuthEvent {}

class AuthGetProfileRequested extends AuthEvent {}

class AuthUpdateProfileSubmitted extends AuthEvent {
  final String fullname;
  final String gender;
  final String ageGroup;
  final String bio;
  final String avatar;
  final double? budget;
  final List<String>? preferences;


  const AuthUpdateProfileSubmitted({
    required this.fullname,
    required this.gender,
    required this.ageGroup,
    required this.bio,
    required this.avatar,
    this.budget,
    this.preferences,
  });
}