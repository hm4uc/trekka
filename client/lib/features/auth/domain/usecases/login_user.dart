import 'package:dartz/dartz.dart';
import 'package:trekka/core/error/failures.dart';
import 'package:trekka/features/auth/domain/entities/user.dart';
import 'package:trekka/features/auth/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<Either<Failure, User>> call(String email, String password) async {
    return await repository.login(email, password);
  }
}