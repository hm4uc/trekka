import 'package:dartz/dartz.dart';
import 'package:trekka/core/error/exceptions.dart';
import 'package:trekka/core/error/failures.dart';
import 'package:trekka/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:trekka/features/auth/data/models/user_model.dart';
import 'package:trekka/features/auth/domain/entities/user.dart';
import 'package:trekka/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final UserModel userModel = await remoteDataSource.login(email, password);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String usrFullname,
    required String usrEmail,
    required String password,
    String? usrGender,
    int? usrAge,
    String? usrJob,
    List<String>? usrPreferences,
    double? usrBudget,
  }) async {
    try {
      final UserModel userModel = await remoteDataSource.register(
        usrFullname: usrFullname,
        usrEmail: usrEmail,
        password: password,
        usrGender: usrGender,
        usrAge: usrAge,
        usrJob: usrJob,
        usrPreferences: usrPreferences,
        usrBudget: usrBudget,
      );
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile(String token) async {
    try {
      final UserModel userModel = await remoteDataSource.getProfile(token);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }
}