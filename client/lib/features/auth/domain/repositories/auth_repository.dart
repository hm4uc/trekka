import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../usecases/update_profile.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register({
    required String fullname,
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> checkAuthStatus();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> logoutAllDevices();
  Future<Either<Failure, User>> updateProfile(UpdateProfileParams params);
}