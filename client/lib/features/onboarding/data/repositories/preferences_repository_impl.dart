import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/travel_constants.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_remote_data_source.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesRemoteDataSource remoteDataSource;

  PreferencesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TravelConstants>> getTravelConstants() async {
    try {
      final result = await remoteDataSource.getTravelConstants();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return const Left(ServerFailure('Lỗi không xác định', 500));

    }
  }
}