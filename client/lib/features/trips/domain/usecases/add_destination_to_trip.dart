import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/trip_repository.dart';

class AddDestinationToTripUseCase {
  final TripRepository repository;

  AddDestinationToTripUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String tripId,
    Map<String, dynamic> destinationData,
  ) async {
    return await repository.addDestinationToTrip(tripId, destinationData);
  }
}

