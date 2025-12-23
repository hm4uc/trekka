import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class GetTripDetailUseCase {
  final TripRepository repository;

  GetTripDetailUseCase(this.repository);

  Future<Either<Failure, Trip>> call(String id) async {
    return await repository.getTripById(id);
  }
}

