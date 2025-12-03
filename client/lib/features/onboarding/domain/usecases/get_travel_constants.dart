import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/travel_constants.dart';
import '../repositories/preferences_repository.dart';

class GetTravelConstants implements UseCase<TravelConstants, NoParams> {
  final PreferencesRepository repository;

  GetTravelConstants(this.repository);

  @override
  Future<Either<Failure, TravelConstants>> call(NoParams params) async {
    return await repository.getTravelConstants();
  }
}