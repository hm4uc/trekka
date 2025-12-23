import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trip.dart';

abstract class TripRepository {
  Future<Either<Failure, Map<String, dynamic>>> getTrips({int page = 1, int limit = 10, String? status});
  Future<Either<Failure, Trip>> getTripById(String id);
  Future<Either<Failure, Trip>> createTrip(Map<String, dynamic> tripData);
  Future<Either<Failure, Trip>> updateTrip(String id, Map<String, dynamic> tripData);
  Future<Either<Failure, void>> deleteTrip(String id);
  Future<Either<Failure, Trip>> updateTripStatus(String id, String status);
  Future<Either<Failure, Map<String, dynamic>>> addDestinationToTrip(String tripId, Map<String, dynamic> destinationData);
  Future<Either<Failure, Map<String, dynamic>>> addEventToTrip(String tripId, Map<String, dynamic> eventData);
}

