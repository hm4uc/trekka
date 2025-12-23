import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class CreateTripUseCase {
  final TripRepository repository;

  CreateTripUseCase(this.repository);

  Future<Either<Failure, Trip>> call(Map<String, dynamic> tripData) async {
    return await repository.createTrip(tripData);
  }
}

