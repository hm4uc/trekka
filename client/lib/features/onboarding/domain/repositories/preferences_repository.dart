import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/travel_constants.dart';

abstract class PreferencesRepository {
  Future<Either<Failure, TravelConstants>> getTravelConstants();
}