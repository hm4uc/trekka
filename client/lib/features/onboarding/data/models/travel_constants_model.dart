import '../../domain/entities/travel_constants.dart';

class TravelConstantsModel extends TravelConstants {
  const TravelConstantsModel({
    required super.styles,
    required super.budgetConfig,
    required super.ageGroup,
    required super.jobs,
    required super.ageMin,
    required super.ageMax,
  });

  factory TravelConstantsModel.fromJson(Map<String, dynamic> json) {
    return TravelConstantsModel(
      styles: (json['travel_styles'] as List)
          .map((e) => TravelStyleModel.fromJson(e))
          .toList(),
      budgetConfig: BudgetConfigModel.fromJson(json['budget_config']),
      ageGroup: List<String>.from(json['age_groups'] ?? []),
      jobs: List<String>.from(json['jobs'] ?? []),
      ageMin: (json['age_min'] as num?)?.toInt() ?? 15,
      ageMax: (json['age_max'] as num?)?.toInt() ?? 150,
    );
  }
}

class TravelStyleModel extends TravelStyle {
  const TravelStyleModel({
    required super.id,
    required super.label,
    required super.icon,
    required super.description,
  });

  factory TravelStyleModel.fromJson(Map<String, dynamic> json) {
    return TravelStyleModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class BudgetConfigModel extends BudgetConfig {
  const BudgetConfigModel({
    required super.min,
    required super.max,
    required super.step,
    required super.defaultValue,
    required super.currency,
  });

  factory BudgetConfigModel.fromJson(Map<String, dynamic> json) {
    return BudgetConfigModel(
      min: (json['MIN'] as num).toDouble(),
      max: (json['MAX'] as num).toDouble(),
      step: (json['STEP'] as num).toDouble(),
      defaultValue: (json['DEFAULT'] as num).toDouble(),
      currency: json['CURRENCY'] ?? 'VND',
    );
  }
}