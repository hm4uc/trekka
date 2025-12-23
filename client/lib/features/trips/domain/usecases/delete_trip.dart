import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/trip_repository.dart';

class DeleteTripUseCase {
  final TripRepository repository;

  DeleteTripUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteTrip(id);
  }
}

