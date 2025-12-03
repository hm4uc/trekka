import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../profile/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register({
    required String fullname,
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> logout();
}