import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/preferences_repository.dart';

// UseCase trả về void hoặc boolean vì ta chỉ cần biết thành công hay không
// API trả về data update, ta có thể ignore hoặc map về Entity nếu cần
class UpdateTravelSettings implements UseCase<void, UpdateTravelSettingsParams> {
  final PreferencesRepository repository;

  UpdateTravelSettings(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTravelSettingsParams params) async {
    return await repository.updateTravelSettings(params);
  }
}

class UpdateTravelSettingsParams extends Equatable {
  final String ageGroup;
  final List<String> preferences;
  final double? budget;

  const UpdateTravelSettingsParams({
    required this.ageGroup,
    required this.preferences,
    this.budget,
  });

  Map<String, dynamic> toJson() => {
    "usr_age_group": ageGroup,
    "usr_preferences": preferences,
    "usr_budget": budget, // Nếu null server sẽ nhận null (hoặc không update)
  };

  @override
  List<Object?> get props => [ageGroup, preferences, budget];
}