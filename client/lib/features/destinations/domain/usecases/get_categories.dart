import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/destination.dart';
import '../repositories/destination_repository.dart';

class GetCategories {
  final DestinationRepository repository;

  GetCategories(this.repository);

  Future<Either<Failure, List<DestinationCategory>>> call() async {
    return await repository.getCategories();
  }
}
