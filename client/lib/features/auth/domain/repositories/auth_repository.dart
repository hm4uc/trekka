import 'package:dartz/dartz.dart';
import 'package:trekka/core/error/failures.dart';
import 'package:trekka/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register({
    required String usrFullname,
    required String usrEmail,
    required String password,
    String? usrGender,
    int? usrAge,
    String? usrJob,
    List<String>? usrPreferences,
    double? usrBudget,
  });
  Future<Either<Failure, User>> getProfile(String token);
}