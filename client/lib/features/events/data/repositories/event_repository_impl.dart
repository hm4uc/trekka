import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_data_source.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EventsResult>> getEvents({
    int page = 1,
    int limit = 10,
    String? search,
    String? eventType,
    double? lat,
    double? lng,
    double radius = 5000,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    try {
      final response = await remoteDataSource.getEvents(
        page: page,
        limit: limit,
        search: search,
        eventType: eventType,
        lat: lat,
        lng: lng,
        radius: radius,
        startDate: startDate,
        endDate: endDate,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
      );

      final data = response['data'];
      final events = (data['data'] as List)
          .map((json) => EventModel.fromJson(json))
          .toList();

      final result = EventsResult(
        total: data['total'],
        currentPage: data['currentPage'],
        totalPages: data['totalPages'],
        events: events,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: ${e.toString()}', 500));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getUpcomingEvents({
    double? lat,
    double? lng,
    double radius = 5000,
    int limit = 10,
  }) async {
    try {
      final events = await remoteDataSource.getUpcomingEvents(
        lat: lat,
        lng: lng,
        radius: radius,
        limit: limit,
      );
      return Right(events);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: ${e.toString()}', 500));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventById(String id) async {
    try {
      final event = await remoteDataSource.getEventById(id);
      return Right(event);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: ${e.toString()}', 500));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> likeEvent(String id) async {
    try {
      final response = await remoteDataSource.likeEvent(id);
      return Right(response['data']);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: ${e.toString()}', 500));
    }
  }

  @override
  Future<Either<Failure, Event>> checkinEvent(String id) async {
    try {
      final event = await remoteDataSource.checkinEvent(id);
      return Right(event);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: ${e.toString()}', 500));
    }
  }
}

