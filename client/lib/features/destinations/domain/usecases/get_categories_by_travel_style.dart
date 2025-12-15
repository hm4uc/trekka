import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/destination.dart';
import '../repositories/destination_repository.dart';

class GetCategoriesByTravelStyle {
  final DestinationRepository repository;

  GetCategoriesByTravelStyle(this.repository);

  Future<Either<Failure, List<DestinationCategory>>> call(String travelStyle) async {
    return await repository.getCategoriesByTravelStyle(travelStyle);
  }
}

