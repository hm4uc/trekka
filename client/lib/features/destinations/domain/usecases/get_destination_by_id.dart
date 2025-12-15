import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/destination.dart';
import '../repositories/destination_repository.dart';

class GetDestinationById {
  final DestinationRepository repository;

  GetDestinationById(this.repository);

  Future<Either<Failure, Destination>> call(String id) async {
    return await repository.getDestinationById(id);
  }
}

