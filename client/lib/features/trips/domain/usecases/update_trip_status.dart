import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class UpdateTripStatusUseCase {
  final TripRepository repository;

  UpdateTripStatusUseCase(this.repository);

  Future<Either<Failure, Trip>> call(String id, String status) async {
    return await repository.updateTripStatus(id, status);
  }
}

