import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/travel_constants.dart';
import '../usecases/update_travel_settings.dart';

abstract class PreferencesRepository {
  Future<Either<Failure, TravelConstants>> getTravelConstants();
  Future<Either<Failure, void>> updateTravelSettings(UpdateTravelSettingsParams params);
}