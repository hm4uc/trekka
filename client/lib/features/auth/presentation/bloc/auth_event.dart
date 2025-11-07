import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginEvent({required this.email, required this.password, required this.rememberMe});

  @override
  List<Object> get props => [email, password, rememberMe];
}

class RegisterEvent extends AuthEvent {
  final String usrFullname;
  final String usrEmail;
  final String password;
  final String? usrGender;
  final int? usrAge;
  final String? usrJob;
  final List<String>? usrPreferences;
  final double? usrBudget;

  const RegisterEvent({
    required this.usrFullname,
    required this.usrEmail,
    required this.password,
    this.usrGender,
    this.usrAge,
    this.usrJob,
    this.usrPreferences,
    this.usrBudget,
  });

  @override
  List<Object> get props {
    return [
      usrFullname,
      usrEmail,
      password,
      usrGender ?? '', // Thay thế null bằng giá trị mặc định
      usrAge ?? -1,    // Thay thế null bằng giá trị mặc định
      usrJob ?? '',    // Thay thế null bằng giá trị mặc định
      usrPreferences ?? <String>[], // Thay thế null bằng list rỗng
      usrBudget ?? -1.0, // Thay thế null bằng giá trị mặc định
    ];
  }
}

class CheckRememberMeEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}