import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/destination_repository.dart';

class SaveDestination {
  final DestinationRepository repository;

  SaveDestination(this.repository);

  Future<Either<Failure, int>> call(String destinationId) async {
    return await repository.saveDestination(destinationId);
  }
}

