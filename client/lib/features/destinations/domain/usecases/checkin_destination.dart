import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/destination_repository.dart';

class CheckinDestination {
  final DestinationRepository repository;

  CheckinDestination(this.repository);

  Future<Either<Failure, int>> call(String destinationId) async {
    return await repository.checkinDestination(destinationId);
  }
}

