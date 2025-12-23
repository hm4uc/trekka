import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/trip_repository.dart';

class GetTripsUseCase {
  final TripRepository repository;

  GetTripsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    return await repository.getTrips(page: page, limit: limit, status: status);
  }
}

