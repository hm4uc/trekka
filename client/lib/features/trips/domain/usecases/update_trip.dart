import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class UpdateTripUseCase {
  final TripRepository repository;

  UpdateTripUseCase(this.repository);

  Future<Either<Failure, Trip>> call(String id, Map<String, dynamic> tripData) async {
    return await repository.updateTrip(id, tripData);
  }
}

