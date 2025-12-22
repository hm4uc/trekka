import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/trip_repository.dart';

class AddEventToTripUseCase {
  final TripRepository repository;

  AddEventToTripUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String tripId,
    Map<String, dynamic> eventData,
  ) async {
    return await repository.addEventToTrip(tripId, eventData);
  }
}

