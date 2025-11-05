import 'package:dartz/dartz.dart';
import 'package:trekka/core/error/failures.dart';
import 'package:trekka/features/auth/domain/entities/user.dart';
import 'package:trekka/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<Either<Failure, User>> call({
    required String usrFullname,
    required String usrEmail,
    required String password,
    String? usrGender,
    int? usrAge,
    String? usrJob,
    List<String>? usrPreferences,
    double? usrBudget,
  }) async {
    return await repository.register(
      usrFullname: usrFullname,
      usrEmail: usrEmail,
      password: password,
      usrGender: usrGender,
      usrAge: usrAge,
      usrJob: usrJob,
      usrPreferences: usrPreferences,
      usrBudget: usrBudget,
    );
  }
}