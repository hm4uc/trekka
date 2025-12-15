import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/destination.dart';
import '../repositories/destination_repository.dart';

class GetNearbyDestinations {
  final DestinationRepository repository;

  GetNearbyDestinations(this.repository);

  Future<Either<Failure, List<Destination>>> call(
    String id, {
    int limit = 5,
    double radius = 2000,
  }) async {
    return await repository.getNearbyDestinations(
      id,
      limit: limit,
      radius: radius,
    );
  }
}

