import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String fullname;
  final String? token; // Token để lưu session

  const User({
    required this.id,
    required this.email,
    required this.fullname,
    this.token,
  });

  @override
  List<Object?> get props => [id, email, fullname, token];
}