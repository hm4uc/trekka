import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTrips({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final result = await remoteDataSource.getTrips(page: page, limit: limit, status: status);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi khi tải danh sách chuyến đi', 500));
    }
  }

  @override
  Future<Either<Failure, Trip>> getTripById(String id) async {
    try {
      final trip = await remoteDataSource.getTripById(id);
      return Right(trip);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi khi tải chi tiết chuyến đi', 500));
    }
  }

  @override
  Future<Either<Failure, Trip>> createTrip(Map<String, dynamic> tripData) async {
    try {
      final trip = await remoteDataSource.createTrip(tripData);
      return Right(trip);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi khi tạo chuyến đi', 500));
    }
  }

  @override
  Future<Either<Failure, Trip>> updateTrip(String id, Map<String, dynamic> tripData) async {
    try {
      final trip = await remoteDataSource.updateTrip(id, tripData);
      return Right(trip);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi khi cập nhật chuyến đi', 500));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrip(String id) async {
    try {
      await remoteDataSource.deleteTrip(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi khi xóa chuyến đi', 500));
    }
  }

  @override
  Future<Either<Failure, Trip>> updateTripStatus(String id, String status) async {
    try {
      final trip = await remoteDataSource.updateTripStatus(id, status);
      return Right(trip);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi khi cập nhật trạng thái chuyến đi', 500));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addDestinationToTrip(
    String tripId,
    Map<String, dynamic> destinationData,
  ) async {
    try {
      final result = await remoteDataSource.addDestinationToTrip(tripId, destinationData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi khi thêm điểm đến vào chuyến đi', 500));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addEventToTrip(
    String tripId,
    Map<String, dynamic> eventData,
  ) async {
    try {
      final result = await remoteDataSource.addEventToTrip(tripId, eventData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi khi thêm sự kiện vào chuyến đi', 500));
    }
  }
}
