import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterWithEmail implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterWithEmail(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      fullname: params.fullname,
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterParams extends Equatable {
  final String fullname;
  final String email;
  final String password;
  const RegisterParams({required this.fullname, required this.email, required this.password});
  @override
  List<Object> get props => [fullname, email, password];
}