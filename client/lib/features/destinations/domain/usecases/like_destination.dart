import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/destination_repository.dart';

class LikeDestination {
  final DestinationRepository repository;

  LikeDestination(this.repository);

  Future<Either<Failure, int>> call(String destinationId) async {
    return await repository.likeDestination(destinationId);
  }
}

